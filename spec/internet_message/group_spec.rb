require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::Group do
  describe '#to_s' do
    let(:display_name){'group'}
    let(:mailbox_list){[double('Mailbox', :to_s=>'hoge@example.com'), double('Mailbox', :to_s=>'fuga@example.net')]}
    subject{InternetMessage::Group.new(display_name, mailbox_list)}
    it 'return group string' do
      subject.to_s.should == 'group: hoge@example.com, fuga@example.net;'
    end
    context 'with display_name including special character' do
      let(:display_name){'hoge.fuga,foo'}
      it 'returns with display_name' do
        subject.to_s.should == '"hoge.fuga,foo": hoge@example.com, fuga@example.net;'
      end
    end
  end
end

