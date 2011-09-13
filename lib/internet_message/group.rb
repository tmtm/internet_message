require "#{File.dirname __FILE__}/tokenizer"

class InternetMessage
  class Group
    def self.parse(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      i = tokens.index(Token.new(:CHAR, ':'))
      j = tokens.index(Token.new(:CHAR, ';')) || tokens.size
      if i and i < j
        display_name = i == 0 ? '' : tokens[0..i-1].join(' ')
        mailbox_list = Mailbox.parse_list(tokens[i+1..j-1])
        Group.new(display_name, mailbox_list)
      else
        Group.new('', Mailbox.parse_list(tokens))
      end
    end

    attr_reader :mailbox_list, :display_name

    def initialize(display_name, mailbox_list)
      @display_name, @mailbox_list = display_name, mailbox_list
    end

    def to_s
      d = @display_name.split(/[ \t]+/).map do |w|
        if w =~ /\A[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+\z/n
          w
        else
          quote_string w
        end
      end.join(' ')
      "#{d}: "+mailbox_list.join(', ')+';'
    end

    private

    def quote_string(s)
      '"'+s.gsub(/[\\\"]/){"\\#{$&}"}+'"'
    end
  end
end
