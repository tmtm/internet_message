class InternetMessage
  class Address

    attr_reader :local_part, :domain

    # @param [String] local_part local part of mail address
    # @param [String] domain domain part of mail address
    def initialize(local_part, domain)
      @local_part, @domain = local_part, domain
    end

    # @return [String] mail address
    def to_s
      if @local_part =~ /\A[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+(\.[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+)*\z/n
        l = @local_part
      else
        l = quote_string(@local_part)
      end
      "#{l}@#{@domain}"
    end

    # @private
    def quote_string(s)
      '"'+s.gsub(/[\\\"]/){"\\#{$&}"}+'"'
    end

    # Compare self to other. local_part and domain are case insensitive.
    # @param [Address] other
    # @return [true, false]
    def ==(other)
      other.is_a?(Address) && other.local_part.downcase == self.local_part.downcase && other.domain.downcase == self.domain.downcase
    end

  end
end
