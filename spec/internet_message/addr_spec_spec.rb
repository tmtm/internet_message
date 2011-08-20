require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe 'InternetMessage::AddrSpec' do
  describe '.parse' do
    it 'return AddrSpec' do
      ret = InternetMessage::AddrSpec.parse('hoge@example.com')
      ret.should be_kind_of InternetMessage::AddrSpec
      ret.local_part.should == 'hoge'
      ret.domain == 'example.com'
    end

    context 'with docomo localpart' do
      it 'treat as valid localpart' do
        ret = InternetMessage::AddrSpec.parse('hoge..fuga@example.com')
        ret.local_part.should == 'hoge..fuga'
        ret.domain == 'example.com'
      end
    end

    context 'with quoted localpart' do
      it 'tread as valid localpart' do
        ret = InternetMessage::AddrSpec.parse('"\\\\(^_^)/"@example.com')
        ret.local_part.should == '\(^_^)/'
        ret.domain == 'example.com'
      end
    end
  end
end



