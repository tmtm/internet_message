require "#{File.dirname __FILE__}/tokenizer"

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
      Mailbox.new(local, domain, display_name)
    end

    attr_reader :local_part, :domain, :display_name

    def initialize(local_part, domain, display_name=nil)
      @local_part, @domain, @display_name = local_part, domain, display_name
    end

    def to_s
      if @local_part =~ /\A[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+(\.[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+)*\z/n
        l = @local_part
      else
        l = quote_string(@local_part)
      end
      if @display_name
        d = @display_name.split(/[ \t]+/).map do |w|
          if w =~ /\A[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+\z/n
            w
          else
            quote_string w
          end
        end.join(' ')
        "#{d} <#{l}@#{@domain}>"
      else
        "#{l}@#{@domain}"
      end
    end

    private

    def quote_string(s)
      '"'+s.gsub(/[\\\"]/){"\\#{$&}"}+'"'
    end
  end
end
