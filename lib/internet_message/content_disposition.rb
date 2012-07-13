require "#{File.dirname __FILE__}/tokenizer"
require "#{File.dirname __FILE__}/content_attribute"

class InternetMessage
  class ContentDisposition

    TOKEN_RE = /[0-9a-zA-Z\!\#\$\%\&\'\*\+\-\.\^\_\`\{\|\}\~]+/i

    # @param [String, Array of Tokenizer] src
    # @return [ContentDisposition]
    # @return [nil] if src is invalid
    def self.parse(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src, :token_re=>TOKEN_RE).tokenize : src.dup
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      unless tokens.size >= 1 && tokens[0].type == :TOKEN
        return nil
      end
      type = tokens[0].value
      tokens.shift
      ContentDisposition.new(type, ContentAttribute.parse_attribute(tokens))
    end

    attr_reader :type, :attribute

    # @param [String] type
    # @param [Hash] attribute
    def initialize(type, attribute={})
      @type, @attribute = type.downcase, attribute
    end

    # Compare self and other.
    # @param [ContentDisposition] other
    # @return [true, false]
    def ==(other)
      other.is_a?(ContentDisposition) && other.type == self.type && other.attribute == self.attribute
    end
  end
end
