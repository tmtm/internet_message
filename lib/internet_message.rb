require 'date'
require 'base64'
require 'mmapscanner'

class InternetMessage
  dir = File.dirname __FILE__
  require "#{dir}/internet_message/header_field"
  require "#{dir}/internet_message/mailbox"
  require "#{dir}/internet_message/group"
  require "#{dir}/internet_message/message_id"
  require "#{dir}/internet_message/received"
  require "#{dir}/internet_message/content_type"
  require "#{dir}/internet_message/content_disposition"

  def initialize(src, opt={})
    @src = MmapScanner.new(src)
    @opt = opt
    @parsed = @parse_multipart = false
    @preamble = @epilogue = nil
    @parts = []
    @rawheader = @rawbody = nil
    @decode_mime_header = opt[:decode_mime_header]
    @fields = []
    @field = Hash.new{|h,k| h[k] = []}
  end

  def close
    if @src.data.respond_to? :unmap
      @src.data.unmap
    end
  end

  def fields
    parse_header
    @fields
  end

  def field
    parse_header
    @field
  end

  [:date, :message_id, :mime_version, :content_transfer_encoding, :content_id, :content_type, :content_disposition].each do |m|
    n = m.to_s.gsub(/_/, '-')
    define_method m do
      f = field[n].first
      f && f.parse
    end
  end

  def from
    f = field['from'].first
    f && f.parse(@decode_mime_header).first
  end

  [:sender, :subject, :content_description].each do |m|
    n = m.to_s.gsub(/_/, '-')
    define_method m do
      f = field[n].first
      f && f.parse(@decode_mime_header)
    end
  end

  [:in_reply_to, :references].each do |m|
    n = m.to_s.gsub(/_/, '-')
    define_method m do
      f = field[n].first
      f && f.parse || []
    end
  end

  [:reply_to, :to, :cc, :bcc].each do |m|
    n = m.to_s.gsub(/_/, '-')
    define_method m do
      f = field[n].first
      f && f.parse(@decode_mime_header) || []
    end
  end

  def comments
    field['comments'].map{|f| f.parse(@decode_mime_header)}
  end

  def keywords
    field['keywords'].map{|f| f.parse(@decode_mime_header)}.flatten
  end

  def trace_blocks
    parse_header
    @trace_blocks
  end

  [:resent_date, :resent_from, :resent_sender, :resent_message_id, :return_path].each do |m|
    define_method m do
      trace = trace_blocks.first
      trace && trace.method(m).call
    end
  end

  [:resent_to, :resent_cc, :resent_bcc, :received].each do |m|
    define_method m do
      trace = trace_blocks.first
      trace ? trace.method(m).call : []
    end
  end

  def type
    content_type ? content_type.type : 'text'
  end

  def subtype
    content_type ? content_type.subtype : 'plain'
  end

  def charset
    (content_type && content_type.attribute['charset']) || 'us-ascii'
  end

  def body
    parse_header
    s = @rawbody.to_s
    case content_transfer_encoding.to_s.downcase
    when 'base64'
      s = Base64.decode64 s
    when 'quoted-printable'
      s = s.unpack('M').join
    end
    s.force_encoding(charset) rescue s
  end

  def preamble
    parse_multipart
    @preamble
  end

  def epilogue
    parse_multipart
    @epilogue
  end

  def parts
    parse_multipart
    @parts
  end

  def message
    type == 'message' ? InternetMessage.new(@rawbody, @opt) : nil
  end

  def self.decode_mime_header_str(str)
    decode_mime_header_words(str.split(/([ \t\r\n]+)/, -1))
  end

  def self.decode_mime_header_words(words)
    ret = ''
    after_mime = nil
    prev_sp = ' '
    words.each do |word|
      s = word.to_s
      if s =~ /\A[ \t\r\n]+\z/
        prev_sp = s
        next
      end
      if (word.is_a?(Token) ? word.type == :TOKEN : true) && s =~ /\A=\?([^?]+)\?([bq])\?([^?]+)\?=\z/i
        charset, enc, data = $1, $2, $3
        if enc.downcase == 'b'
          data = Base64.decode64(data)
        else
          data = data.gsub(/_/,' ').unpack('M').join
        end
        data = data.force_encoding(charset) rescue data
        ret.concat prev_sp if after_mime == false
        ret.concat data.encode(Encoding::UTF_8, :invalid=>:replace, :undef=>:replace)
        after_mime = true
      else
        ret.concat prev_sp unless after_mime.nil?
        ret.concat s
        after_mime = false
      end
    end
    ret
  end

  private

  def split_header_body
    @rawheader = @src.scan_until(/(?=^\r?\n)|\z/)
    @src.skip(/\r?\n/)    # skip delimiter
    @rawbody = @src.rest
  end

  def parse_header
    return if @parsed
    split_header_body
    @trace_blocks = TraceBlockList.new
    while line = @rawheader.scan(/.*(\r?\n[ \t].*)*(?=\r?\n|\z)/n)
      if line.skip(/(.*?):[ \t]*/)
        field_name = line.matched(1).to_s.downcase
        field_value = line.rest
        field = HeaderField.new(field_name, field_value, line)
        @fields.push field
        @field[field_name].push field
        @trace_blocks.push field
      end
      @rawheader.skip(/\r?\n/)
    end
    @trace_blocks.clean
    @parsed = true
  end

  def parse_multipart
    return if @parse_multipart
    return unless content_type
    boundary = content_type.attribute['boundary']
    return unless boundary
    b_re = Regexp.escape boundary
    @rawbody.skip(/(.*?)^--#{b_re}(\r?\n|\z)/nm) or return
    @preamble = @rawbody.matched(1).to_s.chomp
    @parts = []
    last = false
    until last
      @rawbody.skip(/(.*?)\r?\n--#{b_re}(--)?(\r?\n|\z)/nm) or break
      @parts.push InternetMessage.new(@rawbody.matched(1))
      last = true if @rawbody.matched(2)
    end
    @epilogue = @rawbody.rest.to_s
    @parse_multipart = true
  end

  class TraceBlockList
    include Enumerable

    attr_reader :blocks

    def initialize
      @block = TraceBlock.new
      @blocks = [@block]
      @state = nil
    end

    def push(field)
      case field.name
      when 'return-path'
        @block = TraceBlock.new
        @blocks.push @block
        @block.push field
        @state = :return
      when 'received'
        unless @state == :return or @state == :received
          @block = TraceBlock.new
          @blocks.push @block
        end
        @block.push field
        @state = :received
      when /\Aresent-/
        unless @state == :return or @state == :received or @state == :resent
          @block = TraceBlock.new
          @blocks.push @block
        end
        @block.push field
        @state = :resent
      end
    end

    def clean
      @blocks.delete_if(&:empty?)
    end

    def each
      @blocks.each do |b|
        yield b
      end
    end

  end

  class TraceBlock < Array
    def resent_date
      f = self.find{|f| f.name == 'resent-date'}
      f && f.parse
    end

    def resent_from
      f = self.find{|f| f.name == 'resent-from'}
      f && f.parse(@decode_mime_header).first
    end

    def resent_sender
      f = self.find{|f| f.name == 'resent-sender'}
      f && f.parse(@decode_mime_header)
    end

    def resent_to
      f = self.find{|f| f.name == 'resent-to'}
      f ? f.parse(@decode_mime_header) : []
    end

    def resent_cc
      f = self.find{|f| f.name == 'resent-cc'}
      f ? f.parse(@decode_mime_header) : []
    end

    def resent_bcc
      f = self.find{|f| f.name == 'resent-bcc'}
      f ? f.parse(@decode_mime_header) : []
    end

    def resent_message_id
      f = self.find{|f| f.name == 'resent-message-id'}
      f && f.parse
    end

    def return_path
      f = self.find{|f| f.name == 'return-path'}
      f && f.parse
    end

    def received
      self.select{|f| f.name == 'received'}.map{|f| f.parse}.compact
    end
  end
end
