require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::Group do
  describe '.parse' do
    subject{InternetMessage::Group.parse(src)}

    context "for 'group: hoge@example.com, fuga@example.net;'" do
      let(:src){'group: hoge@example.com, fuga@example.net;'}
      its(:display_name){should == 'group'}
      its(:mailbox_list){should == [InternetMessage::Mailbox.new('hoge','example.com'), InternetMessage::Mailbox.new('fuga','example.net')]}
    end

    context "for 'group: hoge@example.com, fuga@example.net'" do
      let(:src){'group: hoge@example.com, fuga@example.net'}
      its(:display_name){should == 'group'}
      its(:mailbox_list){should == [InternetMessage::Mailbox.new('hoge','example.com'), InternetMessage::Mailbox.new('fuga','example.net')]}
    end

    context "for 'group:;'" do
      let(:src){'group:;'}
      its(:display_name){should == 'group'}
      its(:mailbox_list){should be_empty}
    end

    context "for 'group:'" do
      let(:src){'group:'}
      its(:display_name){should == 'group'}
      its(:mailbox_list){should be_empty}
    end

    context "for 'hoge@example.com'" do
      let(:src){'hoge@example.com'}
      its(:display_name){should == ''}
      its(:mailbox_list){should == [InternetMessage::Mailbox.new('hoge','example.com')]}
    end

    context "for ':;'" do
      let(:src){':;'}
      its(:display_name){should == ''}
      its(:mailbox_list){should be_empty}
    end

    context "for ':'" do
      let(:src){':'}
      its(:display_name){should == ''}
      its(:mailbox_list){should be_empty}
    end

  end

  describe '#to_s' do
    let(:display_name){'group'}
    let(:mailbox_list){[double('Mailbox', :to_str=>'hoge@example.com'), double('Mailbox', :to_str=>'fuga@example.net')]}
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

