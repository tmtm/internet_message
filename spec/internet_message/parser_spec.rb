require "#{File.dirname __FILE__}/../../lib/internet_message/parser"

describe InternetMessage::Parser do
  describe '.parse_mailbox_list' do
    it 'return Array of Mailbox' do
      ret = InternetMessage::Parser.parse_mailbox_list('hoge@example.com (comment), "fuga,fuga" <fuga@example.jp>')
      ret[0].local_part.should == 'hoge'
      ret[0].domain.should == 'example.com'
      ret[0].display_name.should be_nil
      ret[1].local_part.should == 'fuga'
      ret[1].domain.should == 'example.jp'
      ret[1].display_name.should == 'fuga,fuga'
    end

    context 'comma' do
      it 'comma is ignored' do
        ret = InternetMessage::Parser.parse_mailbox_list('hoge@example.com,,,,fuga@example.jp')
        ret.size.should == 2
        ret[0].local_part.should == 'hoge'
        ret[1].local_part.should == 'fuga'
      end
    end

  end

  describe '.parse_mailbox' do
    subject{InternetMessage::Parser.parse_mailbox(src)}

    shared_examples_for 'hoge.fuga@example.com' do
      its(:local_part){should == 'hoge.fuga'}
      its(:domain){should == 'example.com'}
    end

    context 'with simple address' do
      let(:src){'hoge.fuga@example.com'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context 'with comment' do
      let(:src){'hoge.fuga@example.com (comment)'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context 'with comment 2' do
      let(:src){'hoge(a).fuga(b)@(c)example.com(d)'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context 'with quoted local-part' do
      let(:src){'"hoge.fuga"@example.com'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context 'with address including space' do
      let(:src){' hoge . fuga @  example .  com '}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context 'with invalid address' do
      let(:src){'hoge..fuga.@example..com'}
      its(:local_part){should == 'hoge..fuga.'}
      its(:domain){should == 'example..com'}
    end
  end

  describe '.parse_address_list' do
    it 'return Array of Mailbox/Group' do
      ret = InternetMessage::Parser.parse_address_list('hoge@example.com (comment), "fuga,fuga" <fuga@example.jp>, group: foo@example.net, bar@example.org;')
      ret[0].local_part.should == 'hoge'
      ret[0].domain.should == 'example.com'
      ret[0].display_name.should be_nil
      ret[1].local_part.should == 'fuga'
      ret[1].domain.should == 'example.jp'
      ret[1].display_name.should == 'fuga,fuga'
      ret[2].display_name.should == 'group'
    end
  end

end

