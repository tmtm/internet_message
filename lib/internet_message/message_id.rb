require "#{File.dirname __FILE__}/tokenizer"

class InternetMessage
  class MessageId
    def self.parse(str)
      tokens = Tokenizer.new(str).tokenize
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      i = tokens.index(Token.new(:CHAR, '<'))
      return unless i
      tokens.shift i+1
      i = tokens.index(Token.new(:CHAR, '>'))
      return unless i
      self.new tokens[0, i].map(&:value).join
    end

    attr_reader :msgid

    def initialize(msgid)
      @msgid = msgid
    end

    def ==(other)
      other.is_a?(MessageId) && other.msgid == self.msgid
    end
  end
end
