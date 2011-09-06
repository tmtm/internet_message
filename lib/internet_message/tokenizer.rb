require 'strscan'

class InternetMessage
  class Tokenizer
    def initialize(s)
      @ss = StringScanner.new(s.gsub(/\r?\n/, ''))
    end

    def tokenize
      ret = []
      until @ss.eos?
        case
        when s = @ss.scan(/[ \t]+/)
          ret.push Token.new(:WSP, s)
        when s = @ss.scan(/[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~\.]+/)
          ret.push Token.new(:DOT_ATOM, s)
        when s = @ss.scan(/\"(\\.|[^\"])+\"/)
          ret.push Token.new(:QUOTED, s.gsub(/\A\"|\"\z/,'').gsub(/\\(.)/){$1})
        when @ss.check(/\(/)
          ret.push Token.new(:COMMENT, scan_comment)
        else
          ret.push Token.new(:CHAR, @ss.scan(/./))
        end
      end
      ret
    end

    def scan_comment
      ret = []
      @ss.scan(/\(/) or return ret
      until @ss.scan(/\)/) or @ss.eos?
        s = @ss.scan(/(\\.|[^\\\(\)])*/) and ret.push s.gsub(/\\(.)/){$1}
        @ss.check(/\(/) and ret.push scan_comment
      end
      ret
    end
  end

  class Token
    attr_reader :type, :value

    def initialize(type, value)
      @type, @value = type, value
    end

    def ==(other)
      other.is_a?(self.class) && other.type == self.type && other.value == self.value
    end
  end

end
