require "#{File.dirname __FILE__}/tokenizer"

class InternetMessage
  class ContentDisposition

    TOKEN_RE = /[0-9a-zA-Z\!\#\$\%\&\'\*\+\-\.\^\_\`\{\|\}\~]+/i

    def self.parse(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src, :token_re=>TOKEN_RE).tokenize : src.dup
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      unless tokens.size >= 1 && tokens[0].type == :TOKEN
        return nil
      end
      type = tokens[0].value
      tokens.shift
      attr = {}
      until tokens.empty?
        break unless tokens.size >= 4 && tokens[0].value == ';' && tokens[2].value == '='
        attr[tokens[1].value.downcase] = tokens[3].value
        tokens.shift 3
      end
      ContentDisposition.new(type, attr)
    end

    attr_reader :type, :attribute

    def initialize(type, attribute={})
      @type, @attribute = type.downcase, attribute
    end

    def ==(other)
      other.is_a?(ContentDisposition) && other.type == self.type && other.attribute == self.attribute
    end
  end
end
