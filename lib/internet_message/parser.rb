require 'strscan'

class InternetMessage
  class Parser
    def initialize(s)
      @ss = s.is_a?(StringScanner) ? s : StringScanner.new(s)
    end

    def parse_dot_atom
      parse_sub do
        skip_cfws
        ret = @ss.scan(/[0-9a-zA-Z\!\#\$\%\^\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+(\.[0-9a-zA-Z\!\#\$\%\^\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+)*/) or raise
        skip_cfws
        ret
      end
    end

    def parse_dot_atom2
      parse_sub do
        skip_cfws
        ret = @ss.scan(/[0-9a-zA-Z\!\#\$\%\^\'\*\+\-\/\=\?\^\_\`\{\|\}\~\.]+/) or raise
        skip_cfws
        ret
      end
    end

    def parse_quoted_string
      parse_sub do
        skip_cfws
        str = @ss.scan(/\"(\\.|[^\"])+\"/) or raise
        skip_cfws
        str.gsub(/\A\"|\"\z/,'').gsub(/\\(.)/){$1}
      end
    end

    def parse_sub
      pos = @ss.pos
      begin
        yield
      rescue RuntimeError
        at = @ss.rest[0, 20]
        @ss.pos = pos
        raise "parse error at: `#{at}'"
      end
    end

    def skip_cfws
      until @ss.eos?
        if @ss.check(/\(/)
          parse_comment
          next
        end
        # CR LF are not included because they are trimmed previous process.
        @ss.scan(/[ \t]+/) or break
      end
    end

    def parse_comment
      parse_sub do
        ret = []
        @ss.scan(/\(/) or raise
        until @ss.scan(/\)/)
          s = @ss.scan(/(\\.|[ \t\x21-\x27\x2a-\x5b\x5d-\x7e])+/) and ret.push s.gsub(/\\(.)/){$1}
          @ss.check(/\(/) and ret.push parse_comment
          raise if @ss.eos?
        end
        ret
      end
    end
  end
end
