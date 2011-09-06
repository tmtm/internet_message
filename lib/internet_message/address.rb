class InternetMessage
  class Address

    attr_reader :local_part, :domain

    def initialize(local_part, domain)
      @local_part, @domain = local_part, domain
    end

    def to_s
      if @local_part =~ /\A[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+(\.[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+)*\z/n
        l = @local_part
      else
        l = quote_string(@local_part)
      end
      "#{l}@#{@domain}"
    end

    def quote_string(s)
      '"'+s.gsub(/[\\\"]/){"\\#{$&}"}+'"'
    end

    def ==(other)
      other.is_a?(Address) && other.local_part.downcase == self.local_part.downcase && other.domain.downcase == self.domain.downcase
    end

  end
end
