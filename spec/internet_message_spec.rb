require "#{File.dirname __FILE__}/../lib/internet_message"

describe 'InternetMessage' do
  subject{InternetMessage.new(src)}
  context 'with simple message' do
    let(:src){<<EOS}
From: TOMITA Masahiro <tommy@tmtm.org>
To: hogehogera <hoge@example.com>, fugafuga <fuga@example.com>
Cc: fugafuga <fuga@example.com>
Subject: test
Content-Type: Text/Plain; charset=UTF-8

body test
EOS
    it '#from returns InternetMessage::Mailbox' do
      subject.from.should == InternetMessage::Mailbox.new('tommy', 'tmtm.org', 'TOMITA Masahiro')
    end
    it '#to returns Array of InternetMessage::Mailbox' do
      subject.to.should be_kind_of Array
      subject.to.size.should == 2
      subject.to.each{|a| a.should be_kind_of InternetMessage::Mailbox}
    end
    it '#cc returns Array of InternetMessage::Mailbox' do
      subject.cc.should be_kind_of Array
      subject.cc.size.should == 1
      subject.cc.each{|a| a.should be_kind_of InternetMessage::Mailbox}
    end
    it '#subject returns String' do
      subject.subject.should == 'test'
    end
    it '#content_type returns ContentType' do
      subject.content_type.should == InternetMessage::ContentType.new('text', 'plain', 'charset'=>'UTF-8')
    end
    it '#type returns String' do
      subject.type.should == 'text'
    end
    it '#subtype returns String' do
      subject.subtype.should == 'plain'
    end
    it '#charset returns String' do
      subject.charset.should == 'UTF-8'
    end
    it '#body returns String' do
      subject.body.should == "body test\n"
      subject.body.encoding.should == Encoding::UTF_8
    end
  end

  context 'with multipart message' do
    let(:src){<<EOS}
Content-Type: Multipart/Mixed; Boundary="abcdefgABCDEFG"

this is preamble.
--abcdefgABCDEFG
Content-Type: text/plain

body1
--abcdefgABCDEFG
Content-Type: text/plain

body2

--abcdefgABCDEFG--
this is epilogue.
EOS
    it '#preamble returns preamble as String' do
      subject.preamble.should == 'this is preamble.'
    end
    it '#epilogue returns epilogue as String' do
      subject.epilogue.should == "this is epilogue.\n"
    end
    it '#parts returns Array of InternetMessage' do
      subject.parts.size.should == 2
      subject.parts[0].body.should == 'body1'
      subject.parts[1].body.should == "body2\n"
    end
  end

end
