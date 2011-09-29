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

  # @param [File, MmapScanner, String] src message source
  # @param [Hash] opt option
  # @option opt [boolean] :decode_mime_header(nil) to decode RFC2047 mime header
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

  # To close object. After close, don't use this object.
  def close
    if @src.data.respond_to? :unmap
      @src.data.unmap
    end
  end

  # @return [Array of HeaderField] Header fields
  def fields
    parse_header
    @fields
  end

  # @return [Hash] 'field-name' => [HeaderField, ...]
  def field
    parse_header
    @field
  end

  defm = proc do |mname|
    fname = mname.to_s.gsub(/_/, '-')
    define_method mname do
      f = field[fname].first
      f && f.parse
    end
  end

  # @method date
  # @return [DateTime] Date field
  defm.call :date

  # @method message_id
  # @return [MessageId] Message-Id field
  defm.call :message_id

  # @method mime_version
  # @return [String] Mime-Version field
  defm.call :mime_version

  # @method content_transfer_encoding
  # @return [String] Content-Transfer-Encoding field
  defm.call :content_transfer_encoding

  # @method content_id
  # @return [MessageId] Content-Id field
  defm.call :content_id

  # @method content_type
  # @return [ContentType] Content-Type field
  defm.call :content_type

  # @method content_disposition
  # @return [ContentDisposition] Content-Dispositoin field
  defm.call :content_disposition

  # @return [Mailbox] From field
  def from
    f = field['from'].first
    f && f.parse(@decode_mime_header).first
  end

  defm = proc do |mname|
    fname = mname.to_s.gsub(/_/, '-')
    define_method mname do
      f = field[fname].first
      f && f.parse(@decode_mime_header)
    end
  end

  # @method sender
  # @return [Mailbox] Sender field
  defm.call :sender

  # @method subject
  # @return [String] Subject field
  defm.call :subject

  # @method content_description
  # @return [String] Content-Description field
  defm.call :content_description

  defm = proc do |mname|
    fname = mname.to_s.gsub(/_/, '-')
    define_method mname do
      f = field[fname].first
      f && f.parse || []
    end
  end

  # @method in_reply_to
  # @return [Array of MessageId] In-Reply-To field
  defm.call :in_reply_to

  # @method references
  # @return [Array of MessageId] References field
  defm.call :references

  defm = proc do |mname|
    fname = mname.to_s.gsub(/_/, '-')
    define_method mname do
      f = field[fname].first
      f && f.parse(@decode_mime_header) || []
    end
  end

  # @method reply_to
  # @return [Array of Mailbox/Group] Reply-To field
  defm.call :reply_to

  # @method to
  # @return [Array of Mailbox/Group] To field
  defm.call :to

  # @method cc
  # @return [Array of Mailbox/Group] Cc field
  defm.call :cc

  # @method bcc
  # @return [Array of Mailbox/Group] Bcc field
  defm.call :bcc

  # @return [Array of String] Comments field
  def comments
    field['comments'].map{|f| f.parse(@decode_mime_header)}
  end

  # @return [Array of String] Keywords field
  def keywords
    field['keywords'].map{|f| f.parse(@decode_mime_header)}.flatten
  end

  # @return [TraceBlockList] trace block list
  def trace_blocks
    parse_header
    @trace_blocks
  end

  defm = proc do |mname|
    define_method mname do
      trace = trace_blocks.first
      trace && trace.method(mname).call
    end
  end

  # @method resent_date
  # @return [DateTime] Resent-Date field of first trace block
  defm.call :resent_date

  # @method resent_from
  # @return [Mailbox] Resent-From field of first trace block
  defm.call :resent_from

  # @method resent_sender
  # @return [Mailbox] Resent-Sender field of first trace block
  defm.call :resent_sender

  # @method resent_message_id
  # @return [MessageId] Resent-Message-Id field of first trace block
  defm.call :resent_message_id

  # @method return_path
  # @return [Address] Return-Path field of first trace block
  defm.call :return_path

  defm = proc do |mname|
    define_method mname do
      trace = trace_blocks.first
      trace ? trace.method(mname).call : []
    end
  end

  # @method resent_to
  # @return [Array of Mailbox/Group] Resent-To field of first trace block
  defm.call :resent_to

  # @method resent_cc
  # @return [Array of Mailbox/Group] Resent-Cc field of first trace block
  defm.call :resent_cc

  # @method resent_bcc
  # @return [Array of Mailbox/Group] Resent-Bcc field of first trace block
  defm.call :resent_bcc

  # @method received
  # @return [Received] Received field of first trace block
  defm.call :received

  # @return [String] media type. 'text' if Content-Type field doesn't exists.
  def type
    content_type ? content_type.type : 'text'
  end

  # @return [String] media subtype. 'plain' if Content-Type field doesn't exists.
  def subtype
    content_type ? content_type.subtype : 'plain'
  end

  # @return [String] charset attribute. 'us-ascii' if Content-Type field doesn't exists.
  def charset
    (content_type && content_type.attribute['charset']) || 'us-ascii'
  end

  # @return [String] body text.
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

  # @return [String] preamble of multiple part message. nil if single part message.
  def preamble
    parse_multipart
    @preamble
  end

  # @return [String] epilogue of multiple part message. nil if single part message.
  def epilogue
    parse_multipart
    @epilogue
  end

  # @return [Array of InternetMessage] parts of multiple part message. empty if single part message.
  def parts
    parse_multipart
    @parts
  end

  # @return [InternetMessage] message if Content-Type is 'message/*'.
  def message
    type == 'message' ? InternetMessage.new(@rawbody, @opt) : nil
  end

  # @private
  def self.decode_mime_header_str(str)
    decode_mime_header_words(str.split(/([ \t\r\n]+)/, -1))
  end

  # @private
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

  # @private
  def split_header_body
    @rawheader = @src.scan_until(/(?=^\r?\n)|\z/)
    @src.skip(/\r?\n/)    # skip delimiter
    @rawbody = @src.rest
  end

  # @private
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

  # @private
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

    # @private
    def initialize
      @block = TraceBlock.new
      @blocks = [@block]
      @state = nil
    end

    # @private
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

    # @private
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
    # @return [DateTime] Resent-Date field in trace block
    def resent_date
      f = self.find{|f| f.name == 'resent-date'}
      f && f.parse
    end

    # @return [Mailbox] Resent-From field in trace block
    def resent_from
      f = self.find{|f| f.name == 'resent-from'}
      f && f.parse(@decode_mime_header).first
    end

    # @return [Mailbox] Resent-Sender field in trace block
    def resent_sender
      f = self.find{|f| f.name == 'resent-sender'}
      f && f.parse(@decode_mime_header)
    end

    # @return [Array of Mailbox/Group] Resent-To field in trace block
    def resent_to
      f = self.find{|f| f.name == 'resent-to'}
      f ? f.parse(@decode_mime_header) : []
    end

    # @return [Array of Mailbox/Group] Resent-Cc field in trace block
    def resent_cc
      f = self.find{|f| f.name == 'resent-cc'}
      f ? f.parse(@decode_mime_header) : []
    end

    # @return [Array of Mailbox/Group] Resent-Bcc field in trace block
    def resent_bcc
      f = self.find{|f| f.name == 'resent-bcc'}
      f ? f.parse(@decode_mime_header) : []
    end

    # @return [MessageId] Resent-Message-Id field in trace block
    def resent_message_id
      f = self.find{|f| f.name == 'resent-message-id'}
      f && f.parse
    end

    # @return [Address] Return-Path field in trace block
    def return_path
      f = self.find{|f| f.name == 'return-path'}
      f && f.parse
    end

    # @return [Array of Received] Received fields in trace block
    def received
      self.select{|f| f.name == 'received'}.map{|f| f.parse}.compact
    end
  end
end
