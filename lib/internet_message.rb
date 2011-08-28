require 'mmapscanner'

class InternetMessage
  dir = File.dirname __FILE__
  require "#{dir}/internet_message/header_field"
  require "#{dir}/internet_message/mailbox"
  require "#{dir}/internet_message/content_type"

  def initialize(src)
    @src = MmapScanner.new(src)
    @header = Hash.new{|h,k| h[k] = []}
  end

  def from
    parse_header
    f = @header['from'].first
    return unless f
    Mailbox.parse f.value.to_s.gsub(/\r?\n/, '')
  end

  def to
    parse_header
    f = @header['to'].first
    f && parse_addrlist(f.value.to_s.gsub(/\r?\n/, ''))
  end

  def cc
    parse_header
    f = @header['cc'].first
    f && parse_addrlist(f.value.to_s.gsub(/\r?\n/, ''))
  end

  def subject
    parse_header
    f = @header['subject'].first
    f && f.value.to_s.gsub(/\r?\n/, '')
  end

  def content_type
    parse_header
    f = @header['content-type'].first
    f && ContentType.parse(f.value.to_s.gsub(/\r?\n/, ''))
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

  private

  def split_header_body
    @rawheader = @src.scan_until(/(?=^\r?\n)|\z/)
    @src.skip(/\r?\n/)    # skip delimiter
    @rawbody = @src.rest
  end

  def parse_header
    return unless @header.empty?
    split_header_body
    while line = @rawheader.scan(/.*(\r?\n[ \t].*)*(?=\r?\n|\z)/n)
      if line.skip(/(.*?):[ \t]*/)
        field_name = line.matched(1).to_s.downcase
        field_value = line.rest
        @header[field_name].push HeaderField.new(field_name, field_value, line)
      end
      @rawheader.skip(/\r?\n/)
    end
  end

  def parse_addrlist(str)
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

end
