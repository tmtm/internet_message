require "#{File.dirname __FILE__}/tokenizer"

class InternetMessage
  class Group
    # @param [String, Array of Tokenizer] src
    # @param [true, false] decode_mime_header Set true to decode MIME header (RFC2047).
    # @return [Group]
    def self.parse(src, decode_mime_header=nil)
      tokens = src.is_a?(String) ? Tokenizer.new(src).tokenize : src.dup
      tokens.delete_if{|t| t.type == :WSP or t.type == :COMMENT}
      i = tokens.index(Token.new(:CHAR, ':'))
      j = tokens.index(Token.new(:CHAR, ';')) || tokens.size
      if i and i < j
        disp_tokens = tokens[0..i-1]
        display_name = i == 0 ? '' : decode_mime_header ? InternetMessage.decode_mime_header_words(disp_tokens) : disp_tokens.join(' ')
        mailbox_list = Mailbox.parse_list(tokens[i+1..j-1], decode_mime_header)
        Group.new(display_name, mailbox_list)
      else
        Group.new('', Mailbox.parse_list(tokens))
      end
    end

    attr_reader :mailbox_list, :display_name

    # @param [String] display_name
    # @param [Array of Mailbox] mailbox_list
    def initialize(display_name, mailbox_list)
      @display_name, @mailbox_list = display_name, mailbox_list
    end

    # @private
    def to_s
      d = @display_name.split(/[ \t]+/).map do |w|
        if w =~ /\A[0-9a-zA-Z\!\#\$\%\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+\z/n
          w
        else
          quote_string w
        end
      end.join(' ')
      "#{d}: "+mailbox_list.join(', ')+';'
    end

    private

    def quote_string(s)
      '"'+s.gsub(/[\\\"]/){"\\#{$&}"}+'"'
    end
  end
end
