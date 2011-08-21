class InternetMessage
  class Group
    attr_reader :mailbox_list, :display_name

    def initialize(display_name, mailbox_list)
      @display_name, @mailbox_list = display_name, mailbox_list
    end

    def to_s
      d = @display_name.split(/[ \t]+/).map do |w|
        if w =~ /\A[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+\z/n
          w
        else
          quote_string w
        end
      end.join(' ')
      "#{d}: "+mailbox_list.map(&:to_s).join(', ')+';'
    end

    private

    def quote_string(s)
      '"'+s.gsub(/[\\\"]/){"\\#{$&}"}+'"'
    end
  end
end
