require "#{File.dirname __FILE__}/tokenizer"
require "#{File.dirname __FILE__}/address"

class InternetMessage
  class Mailbox
    def self.parse(src)
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
      local = i == 0 ? '' : tokens[0..i-1].map(&:value).join
      domain = tokens[i+1..-1].map(&:value).join
      Mailbox.new(Address.new(local, domain), display_name)
    end

    def self.parse_list(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      ret = []
      until tokens.empty?
        i = tokens.index(Token.new(:CHAR, ','))
        break unless i
        if i > 0
          ret.push self.parse(tokens.slice!(0, i))
        end
        tokens.shift
      end
      ret.push self.parse(tokens) unless tokens.empty?
      ret
    end

    attr_reader :address, :display_name

    def initialize(addr, *args)
      if addr.is_a? Address and args.size <= 1
        @address = addr
        @display_name = args.first
      elsif args.size >= 1 and args.size <= 2
        @address = Address.new(addr, args[0])
        @display_name = args[1]
      else
        raise ArgumentError
      end
    end

    def local_part
      @address.local_part
    end

    def domain
      @address.domain
    end

    def to_s
      if @display_name
        d = @display_name.split(/[ \t]+/).map do |w|
          if w =~ /\A[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+\z/n
            w
          else
            quote_string w
          end
        end.join(' ')
        "#{d} <#{@address.to_s}>"
      else
        @address.to_s
      end
    end

    private

    def quote_string(s)
      '"'+s.gsub(/[\\\"]/){"\\#{$&}"}+'"'
    end

    def ==(other)
      other.is_a?(Mailbox) && other.address == self.address && other.display_name == self.display_name
    end
  end
end
