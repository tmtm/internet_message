require 'date'
require "#{File.dirname __FILE__}/tokenizer"

class InternetMessage
  class Received
    def self.parse(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      i = tokens.index(Token.new(:CHAR, ';'))
      return unless i
      date = DateTime.parse(tokens[i+1..-1].join) rescue nil
      tokens = tokens[0, i]

      list = tokens.inject([[]]){|r, t|
        if t.type == :WSP or t.type == :COMMENT
          r.push []
        else
          r.last.push t
        end
        r
      }.reject(&:empty?)

      while list.size >= 2
        case list.shift.join.downcase
        when 'from'
          from = list.shift.join
        when 'by'
          by = list.shift.join
        when 'via'
          via = list.shift.join
        when 'with'
          with = list.shift.join
        when 'id'
          id = list.shift.join
        when 'for'
          m = Mailbox.parse(list.shift)
          for_ = m && m.address
        end
      end
      self.new(from, by, via, with, id, for_, date)
    end

    attr_reader :from, :by, :via, :with, :id, :for, :date

    def initialize(from, by, via, with, id, for_, date)
      @from, @by, @via, @with, @id, @for, @date =
        from, by, via, with, id, for_, date
    end

  end
end
