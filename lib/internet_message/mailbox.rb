require "#{File.dirname __FILE__}/parser"

class InternetMessage
  class Mailbox
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
