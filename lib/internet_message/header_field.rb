class InternetMessage
  class HeaderField
    attr_reader :name, :orig_value, :raw

    def initialize(name, value, raw)
      @name, @orig_value, @raw = name, value, raw
    end

    def value
      @orig_value.to_s
    end
  end
end
