class InternetMessage
  # @private
  module ContentAttribute
    def self.parse_attribute(tokens)
      attr = {}
      until tokens.empty?
        break unless tokens.size >= 4 && tokens[0].value == ';' && tokens[2].value == '='
        attr[tokens[1].value.downcase] = tokens[3].value
        tokens.shift 4
      end

      newattr = {}
      h = Hash.new{|hash,k| hash[k] = []}
      char_lang = {}
      attr.each do |key, value|
        case key
        when /^([^\*]+)(\*0)?\*$/no
          name, ord = $1, $2
          char, lang, v = value.split(/\'/, 3)
          char_lang[name] = [char, lang]
          if v.nil?
            v = lang || char
          end
          v = v.gsub(/%([0-9A-F][0-9A-F])/ni){$1.hex.chr}
          if ord
            h[name] << [0, v]
          else
            newattr[name] = v
          end
        when /^([^\*]+)\*([1-9]\d*)\*$/no
          name, ord = $1, $2.to_i
          v = value.gsub(/%([0-9A-F][0-9A-F])/ni){$1.hex.chr}
          h[name] << [ord, v]
        when /^([^\*]+)\*([0-9]\d*)$/no
          name, ord = $1, $2.to_i
          h[name] << [ord, value]
        else
          newattr[key] = value
        end
      end
      h.each do |k, v|
        newattr[k] = v.sort{|a,b| a[0]<=>b[0]}.map{|a| a[1]}.join
      end
      newattr.keys.each do |k|
        v = newattr[k]
        if char_lang.key? k
          v.force_encoding(char_lang[k][0]) rescue nil
        end
        newattr[k] = v
      end
      return newattr
    end
  end
end
