require 'mmapscanner'

class InternetMessage
  dir = File.dirname __FILE__
  require "#{dir}/internet_message/mailbox"

  def initialize(src)
    @src = MmapScanner.new(src)
  end

  def from
  end

  def to
  end

  def cc
  end

  def type
  end

  def subtype
  end

  def charset
  end

  def body
  end

  class AddrSpec
    attr_reader :local_part, :domain

    def initialize(local_part, domain)
      @local_part, @domain = local_part, domain
    end

    def to_s
      if @local_part =~ /\A[A-Za-z0-9\!\#\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+(\.[A-Za-z0-9\!\#\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+)*\z/
        "#{@local_part}@#{@domain}"
      else
        '"'+@local_part.gsub(/[\x00-\x20\"\\\x7f-\xff]/n){"\\#{$&}"}+'"@'+@domain
      end
    end
  end
end
