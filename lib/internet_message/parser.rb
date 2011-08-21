require "#{File.dirname __FILE__}/tokenizer"
require "#{File.dirname __FILE__}/mailbox"
require "#{File.dirname __FILE__}/group"

class InternetMessage
  module Parser
    module_function
    def parse_mailbox(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      if i = tokens.index(Token.new(:CHAR, '<'))
        display_name = tokens[0..i-1].map(&:value).join(' ')
        if j = tokens.index(Token.new(:CHAR, '>'))
          tokens = tokens[i+1..j-1]
        else
          tokens = tokens[i+1..-1]
        end
      end
      i = tokens.rindex(Token.new(:CHAR, '@'))
      local = tokens[0..i-1].map(&:value).join
      domain = tokens[i+1..-1].map(&:value).join
      Mailbox.new(local, domain, display_name)
    end

    def parse_mailbox_list(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      ret = []
      m = []
      while t = tokens.shift
        if t.type == :CHAR and t.value == ','
          ret.push parse_mailbox(m) unless m.empty?
          m = []
        else
          m.push t
        end
      end
      ret.push parse_mailbox(m) unless m.empty?
      ret
    end

    def parse_address(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      i = tokens.index(Token.new(:CHAR, ':'))
      j = tokens.index(Token.new(:CHAR, ';'))
      if i and i > 0 and j and i < j
        display_name = tokens[0..i-1].map(&:value).join(' ')
        mailbox_list = parse_mailbox_list(tokens[i+1..j-1])
        Group.new(display_name, mailbox_list)
      else
        parse_mailbox(tokens)
      end
    end

    def parse_address_list(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      ret = []
      m = []
      while t = tokens.shift
        if t.type == :CHAR and t.value == ':' and i = tokens.index(Token.new(:CHAR, ';'))
          m.push t
          m.concat tokens.slice!(0..i)
        elsif t.type == :CHAR and t.value == ','
          ret.push parse_address(m) unless m.empty?
          m = []
        else
          m.push t
        end
      end
      ret.push parse_address(m) unless m.empty?
      ret
    end

  end
end
