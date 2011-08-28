class InternetMessage
  class ContentType
    def self.parse(src)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      unless tokens.size >= 3 && tokens[0].type == :TOKEN && tokens[1].value == '/' && tokens[2].type == :TOKEN
        return nil
      end
      type, subtype = tokens[0].value, tokens[2].value
      tokens.shift 3
      attr = {}
      until tokens.empty?
        break unless tokens.size >= 4 && tokens[0].value == ';' && tokens[2].value == '='
        attr[tokens[1].value.downcase] = tokens[3].value
        tokens.shift 3
      end
      ContentType.new(type, subtype, attr)
    end

    attr_reader :type, :subtype, :attribute

    def initialize(type, subtype, attribute={})
      @type, @subtype, @attribute = type.downcase, subtype.downcase, attribute
    end

    def ==(other)
      other.is_a?(ContentType) && other.type == self.type && other.subtype == self.subtype && other.attribute == self.attribute
    end

    class Tokenizer
      def initialize(s)
        @ss = StringScanner.new(s)
      end

      def tokenize
        ret = []
        until @ss.eos?
          case
          when s = @ss.scan(/[ \t]+/)
            ret.push Token.new(:WSP, s)
          when s = @ss.scan(/[0-9a-zA-Z\!\#\$\%\&\'\*\+\-\.\^\_\`\{\|\}\~]+/)
            ret.push Token.new(:TOKEN, s)
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
  end
end

