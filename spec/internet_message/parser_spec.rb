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

