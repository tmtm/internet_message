require 'date'
require "#{File.dirname __FILE__}/tokenizer"

class InternetMessage
  class Received
    def self.parse(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      i = tokens.index(Token.new(:CHAR, ';'))
      return unless i
      date = DateTime.parse(tokens[i+1..-1].map(&:value).join) rescue nil
      tokens = tokens[0, i]
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      param = {}
      tokens.each_slice(2){|key, val| param[key.value.downcase] = val.value}
      self.new(*param.values_at('from', 'by', 'via', 'with', 'id', 'for'), date)
    end

    attr_reader :from, :by, :via, :with, :id, :for, :date

    def initialize(from, by, via, with, id, for_, date)
      @from, @by, @via, @with, @id, @for, @date =
        from, by, via, with, id, for_, date
    end

  end
end
