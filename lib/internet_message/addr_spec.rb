require "#{File.dirname __FILE__}/parser"

class InternetMessage
  class AddrSpec
    def self.parse(s)
      Parser.new(s).parse
    end

    attr_reader :local_part, :domain

    def initialize(local_part, domain)
      @local_part, @domain = local_part, domain
    end

    class Parser < InternetMessage::Parser
      def parse
        parse_sub do
          local_part = parse_local_part
          @ss.scan(/@/) or raise
          domain = parse_domain
          AddrSpec.new(local_part, domain)
        end
      end

      def parse_local_part
        parse_dot_atom2 rescue parse_quoted_string
      end

      def parse_domain
        parse_dot_atom rescue parse_domain_literal
      end
    end
  end
end
