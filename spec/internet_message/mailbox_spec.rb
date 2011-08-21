require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::Mailbox do
  describe '#to_s' do
    let(:local_part){'hoge'}
    let(:domain){'example.com'}
    let(:display_name){nil}
    subject{InternetMessage::Mailbox.new(local_part, domain, display_name)}
    context 'simple address' do
      it 'return mailaddress' do
        subject.to_s.should == 'hoge@example.com'
      end
    end

    context 'localpart including special character' do
      let(:local_part){'hoge"fuga\\foo'}
      it 'quote localpart' do
        subject.to_s.should == '"hoge\\"fuga\\\\foo"@example.com'
      end
    end

    context 'localpart including ".."' do
      let(:local_part){'hoge..fuga'}
      it 'quote localpart' do
        subject.to_s.should == '"hoge..fuga"@example.com'
      end
    end

    context 'with simple display_name' do
      let(:display_name){'hoge fuga'}
      it 'returns with display_name' do
        subject.to_s.should == 'hoge fuga <hoge@example.com>'
      end
    end

    context 'with display_name including special character' do
      let(:display_name){'hoge.fuga,foo'}
      it 'returns with display_name' do
        subject.to_s.should == '"hoge.fuga,foo" <hoge@example.com>'
      end
    end
  end
end

