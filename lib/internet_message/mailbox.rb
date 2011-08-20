require "#{File.dirname __FILE__}/parser"
require "#{File.dirname __FILE__}/addr_spec"

class InternetMessage
  class Mailbox
    def self.parse(str)
      Parser.new(str).parse
    end

    attr_reader :addr_spec, :display_name

    def initialize(addr_spec, display_name=nil)
      @addr_spec, @display_name = addr_spec, display_name
    end

    def local_part
      @addr_spec.local_part
    end

    def domain
      @addr_spec.domain
    end

    def to_s
      if display_name
        "#{@display_name} <#{@addr_spec}>"
      else
        @addr_spec.to_s
      end
    end

    class Parser < InternetMessage::Parser
      def parse
        parse_name_addr rescue parse_addr_spec
      end

      def parse_name_addr
        parse_display_name rescue nil
        parse_angle_addr
      end

      def parse_display_name
        parse_phrase
      end

      def parse_angle_addr
        parse_sub do
          skip_cfws
          @ss.scan(/</) or raise
          parse_addr_spec
          @ss.scan(/>/) or raise
          skip_cfws
        end
      end

      def parse_addr_spec
        parse_sub do
          AddrSpec.parse(@ss)
        end
      end
    end
  end
end
