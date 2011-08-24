class InternetMessage
  class HeaderField
    attr_reader :name, :value, :raw

    def initialize(name, value, raw)
      @name, @value, @raw = name, value, raw
    end
  end
end
