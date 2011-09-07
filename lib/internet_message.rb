require 'date'
require 'mmapscanner'

class InternetMessage
  dir = File.dirname __FILE__
  require "#{dir}/internet_message/header_field"
  require "#{dir}/internet_message/mailbox"
  require "#{dir}/internet_message/message_id"
  require "#{dir}/internet_message/received"
  require "#{dir}/internet_message/content_type"
  require "#{dir}/internet_message/content_disposition"

  def initialize(src)
    @src = MmapScanner.new(src)
    @header = Hash.new{|h,k| h[k] = []}
    @parse_multipart = false
    @preamble = @epilogue = nil
    @parts = []
  end

  def date
    parse_header
    f = @header['date'].first
    f && DateTime.parse(f.value.to_s.gsub(/\r?\n/, '')) rescue nil
  end

  def from
    parse_header
    f = @header['from'].first
    f && Mailbox.parse(f.value.to_s)
  end

  def sender
    parse_header
    f = @header['sender'].first
    f && Mailbox.parse(f.value.to_s)
  end

  def reply_to
    parse_header
    f = @header['reply-to'].first
    f && self.class.parse_addrlist(f.value.to_s)
  end

  def to
    parse_header
    f = @header['to'].first
    f && self.class.parse_addrlist(f.value.to_s)
  end

  def cc
    parse_header
    f = @header['cc'].first
    f && self.class.parse_addrlist(f.value.to_s)
  end

  def bcc
    parse_header
    f = @header['bcc'].first
    f && self.class.parse_addrlist(f.value.to_s)
  end

  def message_id
    parse_header
    f = @header['message-id'].first
    f && MessageId.parse(f.value.to_s)
  end

  def in_reply_to
    parse_header
    f = @header['in-reply-to'].first
    f && MessageId.parse_list(f.value.to_s)
  end

  def references
    parse_header
    f = @header['references'].first
    f && MessageId.parse_list(f.value.to_s)
  end

  def comments
    parse_header
    @header['comments'].to_a.map{|f| f.value.to_s.gsub(/\r?\n/, '')}
  end

  def keywords
    parse_header
    keys = []
    @header['keywords'].to_a.map do |f|
      tokens = Tokenizer.new(f.value.to_s).tokenize
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      while true
        i = tokens.index(Token.new(:CHAR, ','))
        break unless i
        if i > 0
          keys.push tokens[0, i].map(&:value).join(' ')
        end
        tokens.shift i+1
      end
      keys.push tokens.map(&:value).join(' ') unless tokens.empty?
    end
    keys
  end

  [:resent_date, :resent_from, :resent_sender, :resent_to, :resent_cc,
    :resent_bcc, :resent_message_id, :return_path, :received].each do |m|
    define_method m do
      parse_header
      trace = @trace_blocks.first
      trace && trace.method(m).call
    end
  end

  def mime_version
    parse_header
    f = @header['mime-version'].first
    return unless f
    tokens = Tokenizer.new(f.value.to_s).tokenize
    tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
    tokens.map(&:value).join
  end

  def content_transfer_encoding
    parse_header
    f = @header['content-transfer-encoding'].first
    return unless f
    tokens = Tokenizer.new(f.value.to_s).tokenize
    tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
    tokens.map(&:value).join
  end

  def content_id
    parse_header
    f = @header['content-id'].first
    f && MessageId.parse(f.value.to_s)
  end

  def subject
    parse_header
    f = @header['subject'].first
    f && f.value.to_s.gsub(/\r?\n/, '')
  end

  def content_type
    parse_header
    f = @header['content-type'].first
    f && ContentType.parse(f.value.to_s)
  end

  def content_description
    parse_header
    f = @header['content-description'].first
    f && f.value.to_s.gsub(/\r?\n/, '')
  end

  def content_disposition
    parse_header
    f = @header['content-disposition'].first
    f && ContentDisposition.parse(f.value.to_s)
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

  def self.parse_addrlist(str)
    ret = []
    tokens = Tokenizer.new(str).tokenize
    tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
    until tokens.empty?
      i = tokens.index(Token.new(:CHAR, ','))
      if i == 0
        tokens.shift
        next
      end
      j = tokens.index(Token.new(:CHAR, ':'))
      if i && j && j < i || !i && j
        i = tokens.index(Token.new(:CHAR, ';')) || -1
        ret.push Group.parse(tokens.slice!(0..i))
      elsif i
        ret.push Mailbox.parse(tokens.slice!(0..i-1))
      else
        ret.push Mailbox.parse(tokens)
        tokens.clear
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
    return unless @header.empty?
    split_header_body
    @trace_blocks = TraceBlockList.new
    while line = @rawheader.scan(/.*(\r?\n[ \t].*)*(?=\r?\n|\z)/n)
      if line.skip(/(.*?):[ \t]*/)
        field_name = line.matched(1).to_s.downcase
        field_value = line.rest
        field = HeaderField.new(field_name, field_value, line)
        @header[field_name].push field
        @trace_blocks.push field
      end
      @rawheader.skip(/\r?\n/)
    end
    @trace_blocks.clean
  end

  def parse_multipart
    return if @parse_multipart
    boundary = content_type.attribute['boundary']
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
      f && DateTime.parse(f.value.to_s.gsub(/\r?\n/, '')) rescue nil
    end

    def resent_from
      f = self.find{|f| f.name == 'resent-from'}
      f && Mailbox.parse(f.value.to_s)
    end

    def resent_sender
      f = self.find{|f| f.name == 'resent-sender'}
      f && Mailbox.parse(f.value.to_s)
    end

    def resent_to
      f = self.find{|f| f.name == 'resent-to'}
      f && InternetMessage.parse_addrlist(f.value.to_s)
    end

    def resent_cc
      f = self.find{|f| f.name == 'resent-cc'}
      f && InternetMessage.parse_addrlist(f.value.to_s)
    end

    def resent_bcc
      f = self.find{|f| f.name == 'resent-bcc'}
      f && InternetMessage.parse_addrlist(f.value.to_s)
    end

    def resent_message_id
      f = self.find{|f| f.name == 'resent-message-id'}
      f && MessageId.parse(f.value.to_s)
    end

    def return_path
      f = self.find{|f| f.name == 'return-path'}
      return unless f
      tokens = Tokenizer.new(f.value.to_s).tokenize
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      i = tokens.index(Token.new(:CHAR, '<'))
      return unless i
      tokens.shift i+1
      i = tokens.index(Token.new(:CHAR, '>'))
      return unless i
      tokens = tokens[0, i]
      i = tokens.rindex(Token.new(:CHAR, '@'))
      if i
        Address.new(tokens[0, i].map(&:value).join, tokens[i+1..-1].map(&:value).join)
      else
        nil
      end
    end

    def received
      self.select{|f| f.name == 'received'}.map do |f|
        Received.parse f.value.to_s
      end
    end
  end
end
