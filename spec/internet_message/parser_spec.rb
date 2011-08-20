require "#{File.dirname __FILE__}/../../lib/internet_message/parser"

describe InternetMessage::Parser do
  subject{InternetMessage::Parser.new(src)}
  describe '#parse_dot_atom' do
    context 'with valid dot-atom' do
      let(:src){'aaa.bbb.ccc'}
      it 'return String' do
        subject.parse_dot_atom.should == 'aaa.bbb.ccc'
      end
    end

    context 'with continuing dot' do
      let(:src){'aaa...bbb'}
      it 'treat valid dot-atom (out of rules)' do
        subject.parse_dot_atom.should == 'aaa'
      end
    end

    context 'with not dot-atom' do
      let(:src){'<aaa.bbb>'}
      it 'raise error' do
        expect{subject.parse_dot_atom}.to raise_error(RuntimeError, "parse error at: `<aaa.bbb>'")
      end
    end
  end

  describe '#parse_dot_atom2' do
    context 'with valid dot-atom' do
      let(:src){'aaa.bbb.ccc'}
      it 'return String' do
        subject.parse_dot_atom2.should == 'aaa.bbb.ccc'
      end
    end

    context 'with continuing dot' do
      let(:src){'aaa...bbb'}
      it 'treat valid dot-atom (out of rules)' do
        subject.parse_dot_atom2.should == 'aaa...bbb'
      end
    end

    context 'with not dot-atom' do
      let(:src){'<aaa.bbb>'}
      it 'raise error' do
        expect{subject.parse_dot_atom2}.to raise_error(RuntimeError, "parse error at: `<aaa.bbb>'")
      end
    end
  end

  describe '#parse_quoted_string' do
    context 'with quoted-string' do
      let(:src){'"hoge\"fuga\\"'}
      it 'returns unquoed string' do
        subject.parse_quoted_string.should == 'hoge"fuga\\'
      end
    end

    context 'with not quoted-string' do
      let(:src){'hoge'}
      it 'raise error' do
        expect{subject.parse_quoted_string}.to raise_error(RuntimeError, "parse error at: `hoge'")
      end
    end
  end

  describe '#skip_cfws' do
    context 'with WSP' do
      let(:src){" \t \t \t hoge"}
      it 'skip WSP' do
        subject.skip_cfws
        subject.instance_variable_get(:@ss).rest.should == 'hoge'
      end
    end

    context 'with comment' do
      let(:src){'  (hoge (fuga)) hoge'}
      it 'skip comment and WSP' do
        subject.skip_cfws
        subject.instance_variable_get(:@ss).rest.should == 'hoge'
      end
    end
  end

  describe '#parse_comment' do
    context 'with one level comment' do
      let(:src){'(hoge fuga)'}
      it 'return comment string' do
        subject.parse_comment.should == ['hoge fuga']
      end
    end

    context 'with "\)"' do
      let(:src){'(hoge\))'}
      it 'treat as not special char' do
        subject.parse_comment.should == ['hoge)']
      end
    end

    context 'with nested comment' do
      let(:src){'(hoge (fuga (hage) moge) )'}
      it 'return comment string' do
        subject.parse_comment.should == ['hoge ', ['fuga ', ['hage'], ' moge'], ' ']
      end
    end

    context 'with unclosed comment' do
      let(:src){'(hoge (fuga)'}
      it 'raise error' do
        expect{subject.parse_comment}.to raise_error(RuntimeError, 'parse error at: `\'')
      end
    end
  end


end

