require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::Tokenizer do
  subject{InternetMessage::Tokenizer.new(src)}
  describe '#tokenize' do
    def token(type, value)
      InternetMessage::Token.new(type, value)
    end

    let(:src){' "hoge\"fuga\\\\hero" < hoge.fuga@ example.com(a)> (foo(bar)) '}
    it 'returns Array of Token' do
      ret = subject.tokenize
      ret.shift.should == token(:WSP,      ' ')
      ret.shift.should == token(:QUOTED,   'hoge"fuga\\hero')
      ret.shift.should == token(:WSP,      ' ')
      ret.shift.should == token(:CHAR,     '<')
      ret.shift.should == token(:WSP,      ' ')
      ret.shift.should == token(:TOKEN,    'hoge.fuga')
      ret.shift.should == token(:CHAR,     '@')
      ret.shift.should == token(:WSP,      ' ')
      ret.shift.should == token(:TOKEN,    'example.com')
      ret.shift.should == token(:COMMENT,  ['a'])
      ret.shift.should == token(:CHAR,     '>')
      ret.shift.should == token(:WSP,      ' ')
      ret.shift.should == token(:COMMENT,  ['foo', ['bar']])
      ret.shift.should == token(:WSP,      ' ')
    end
  end

  describe '#scan_comment' do
    context 'with one level comment' do
      let(:src){'(hoge fuga)'}
      it 'return comment string' do
        subject.scan_comment.should == ['hoge fuga']
      end
    end

    context 'with "\)"' do
      let(:src){'(hoge\))'}
      it 'treat as not special char' do
        subject.scan_comment.should == ['hoge)']
      end
    end

    context 'with nested comment' do
      let(:src){'(hoge (fuga (hage) moge) )'}
      it 'return comment string' do
        subject.scan_comment.should == ['hoge ', ['fuga ', ['hage'], ' moge'], ' ']
      end
    end

    context 'with unclosed comment' do
      let(:src){'(hoge (fuga)'}
      it 'return comment' do
        subject.scan_comment.should == ['hoge ', ['fuga']]
      end
    end
  end
end
