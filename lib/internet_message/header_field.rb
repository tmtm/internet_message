require "#{File.dirname __FILE__}"
require "#{File.dirname __FILE__}/tokenizer"
require "#{File.dirname __FILE__}/mailbox"
require "#{File.dirname __FILE__}/message_id"
require "#{File.dirname __FILE__}/content_type"
require "#{File.dirname __FILE__}/content_disposition"
require "#{File.dirname __FILE__}/group"
require "#{File.dirname __FILE__}/received"

class InternetMessage
  class HeaderField
    # @param [MmapScanner] raw
    # @return [InternetMessage::HeaderField]
    # @return [nil] if raw is invalid
    def self.parse(raw)
      return nil unless raw.skip(/(.*?):[ \t]*/)
      name = raw.matched(1).to_s.downcase
      value = raw.rest
      HeaderField.new(name, value, raw)
    end

    attr_reader :name, :orig_value, :raw

    # @param [String] name field name
    # @param [MmapScanner] value field value
    # @param [MmapScanner] raw field line
    def initialize(name, value, raw)
      @name, @orig_value, @raw = name, value, raw
    end

    # @return [String] value as String
    def value
      @orig_value.to_s
    end

    # @param [true, false] decode_mime_header Set true to decode MIME header (RFC2047).
    # @return parsed value
    def parse(decode_mime_header=nil)
      case @name
      when 'date', 'resent-date'
        DateTime.parse(value.gsub(/\r?\n/, '')) rescue nil
      when 'from', 'resent-from'
        self.class.parse_mailboxlist(value, decode_mime_header)
      when 'sender', 'resent-sender'
        Mailbox.parse(value, decode_mime_header)
      when 'message-id', 'content-id', 'resent-message-id'
        MessageId.parse(value)
      when 'in-reply-to', 'references'
        MessageId.parse_list(value)
      when 'mime-version', 'content-transfer-encoding'
        tokens = Tokenizer.new(value).tokenize2
        tokens.empty? ? nil : tokens.join
      when 'content-type'
        ContentType.parse(value)
      when 'content-disposition'
        ContentDisposition.parse(value)
      when 'reply-to', 'to', 'cc', 'bcc', 'resent-to', 'resent-cc', 'resent-bcc'
        self.class.parse_addrlist(value, decode_mime_header)
      when 'keywords'
        self.class.parse_keywords(value, decode_mime_header)
      when 'return-path'
        self.class.parse_return_path(value)
      when 'received'
        Received.parse value
      else
        s = value.gsub(/\r?\n/, '')
        decode_mime_header ? InternetMessage.decode_mime_header_str(s) : s
      end
    end

    # @private
    def self.parse_mailboxlist(str, decode_mime_header=nil)
      ret = []
      tokens = Tokenizer.new(str).tokenize2
      until tokens.empty?
        i = tokens.index(Token.new(:CHAR, ','))
        if i == 0
          tokens.shift
          next
        end
        if i
          ret.push Mailbox.parse(tokens.slice!(0..i-1), decode_mime_header)
        else
          ret.push Mailbox.parse(tokens, decode_mime_header)
          tokens.clear
        end
      end
      ret
    end

    # @private
    def self.parse_addrlist(str, decode_mime_header=nil)
      ret = []
      tokens = Tokenizer.new(str).tokenize2
      until tokens.empty?
        i = tokens.index(Token.new(:CHAR, ','))
        if i == 0
          tokens.shift
          next
        end
        j = tokens.index(Token.new(:CHAR, ':'))
        if i && j && j < i || !i && j
          i = tokens.index(Token.new(:CHAR, ';')) || -1
          ret.push Group.parse(tokens.slice!(0..i), decode_mime_header)
        elsif i
          ret.push Mailbox.parse(tokens.slice!(0..i-1), decode_mime_header)
        else
          ret.push Mailbox.parse(tokens, decode_mime_header)
          tokens.clear
        end
      end
      ret
    end

    # @private
    def self.parse_keywords(str, decode_mime_header=nil)
      keys = []
      tokens = Tokenizer.new(str).tokenize2
      while true
        i = tokens.index(Token.new(:CHAR, ','))
        break unless i
        if i > 0
          key = decode_mime_header ? InternetMessage.decode_mime_header_words(tokens[0, i]) : tokens[0, i].join(' ')
          keys.push key
        end
        tokens.shift i+1
      end
      unless tokens.empty?
        key = decode_mime_header ? InternetMessage.decode_mime_header_words(tokens) : tokens.join(' ')
        keys.push key
      end
      keys
    end

    # @private
    def self.parse_return_path(str)
      tokens = Tokenizer.new(str).tokenize2
      i = tokens.index(Token.new(:CHAR, '<'))
      return unless i
      tokens.shift i+1
      i = tokens.index(Token.new(:CHAR, '>'))
      return unless i
      tokens = tokens[0, i]
      i = tokens.rindex(Token.new(:CHAR, '@'))
      i && Address.new(tokens[0, i].join, tokens[i+1..-1].join)
    end
  end
end
