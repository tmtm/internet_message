require "#{File.dirname __FILE__}/tokenizer"
require "#{File.dirname __FILE__}/content_attribute"

class InternetMessage
  class ContentType

    TOKEN_RE = /[0-9a-zA-Z\!\#\$\%\&\'\*\+\-\.\^\_\`\{\|\}\~]+/i

    # @param [String, Array of Tokenizer] src
    # @return [ContentType]
    # @return [nil] if src is invalid
    def self.parse(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src, :token_re=>TOKEN_RE).tokenize : src.dup
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      unless tokens.size >= 3 && tokens[0].type == :TOKEN && tokens[1].value == '/' && tokens[2].type == :TOKEN
        return nil
      end
      type, subtype = tokens[0].value, tokens[2].value
      tokens.shift 3
      ContentType.new(type, subtype, ContentAttribute.parse_attribute(tokens))
    end

    attr_reader :type, :subtype, :attribute

    # @param [String] type
    # @param [String] subtype
    # @param [Hash] attribute
    def initialize(type, subtype, attribute={})
      @type, @subtype, @attribute = type.downcase, subtype.downcase, attribute
    end

    # Compare self and other
    # @param [ContentType] other
    # @return [true, false]
    def ==(other)
      other.is_a?(ContentType) && other.type == self.type && other.subtype == self.subtype && other.attribute == self.attribute
    end
  end
end
