require "#{File.dirname __FILE__}/../lib/internet_message"

describe 'InternetMessage' do
  subject{InternetMessage.new(src)}
  context 'with simple message' do
    let(:src){<<EOS}
Return-Path: <hoge@example.com>
Received: from example.net (localhost) by example.com
 with SMTP id HOGEHOGE; Tue, 6 Sep 2011 19:49:44 +0900
Received: from example.org (localhost) by example.net
 with SMTP id FUGAFUGA; Tue, 6 Sep 2011 19:49:43 +0900
Resent-Date: Tue, 6 Sep 2011 19:49:42 +0900
Resent-From: hoge@example.com
Resent-Sender: fuga@example.net
Resent-To: test@example.jp, test2@example.test
Resent-Cc: test3@example.net
Resent-Bcc:test4@example.org
Resent-Message-Id: <hoge.fuga@example.com>
From: TOMITA Masahiro <tommy@tmtm.org>
Sender: TOMITA Masahiro <tommy@tmtm.org>
Reply-To: hogehogera <hoge@example.com>, fugafuga <fuga@example.com>
To: hogehogera <hoge@example.com>, fugafuga <fuga@example.com>
Cc: fugafuga <fuga@example.com>
Bcc: fugafuga <fuga@example.com>
Subject: test
Content-Type: Text/Plain; charset=UTF-8
Date: Sun, 4 Sep 2011 23:14:45 +0900 (JST)
Message-Id: <20101203223001.5C9523E3A70@note.tmtm.org>
In-Reply-To: <a.b@example.net> <c.d@example.com>
References: <a.b@example.net> <c.d@example.com>
Comments: This is comment message.
Keywords: hoge, fuga, foo, bar
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Id: <a.b@example.com>
Content-Description: Description of Contents
Content-Disposition: inline; filename="hoge.txt"

body test
EOS
    it '#date returns DateTime' do
      subject.date.should == DateTime.new(2011, 9, 4, 23, 14, 45, '+0900')
    end
    it '#from returns InternetMessage::Mailbox' do
      subject.from.should == InternetMessage::Mailbox.new('tommy', 'tmtm.org', 'TOMITA Masahiro')
    end
    it '#sender returns InternetMessage::Mailbox' do
      subject.sender.should == InternetMessage::Mailbox.new('tommy', 'tmtm.org', 'TOMITA Masahiro')
    end
    it '#reply_to returns Array of InternetMessage::Mailbox' do
      subject.reply_to.should be_kind_of Array
      subject.reply_to.size.should == 2
      subject.reply_to.each{|a| a.should be_kind_of InternetMessage::Mailbox}
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
    it '#bcc returns Array of InternetMessage::Mailbox' do
      subject.bcc.should be_kind_of Array
      subject.bcc.size.should == 1
      subject.bcc.each{|a| a.should be_kind_of InternetMessage::Mailbox}
    end
    it '#message_id returns InternetMessage::MessageId' do
      subject.message_id.should == InternetMessage::MessageId.new('20101203223001.5C9523E3A70@note.tmtm.org')
    end
    it '#in_reply_to returns Array of InternetMessage::MessageId' do
      subject.in_reply_to.should == [
        InternetMessage::MessageId.new('a.b@example.net'),
        InternetMessage::MessageId.new('c.d@example.com')
      ]
    end
    it '#references returns Array of InternetMessage::MessageId' do
      subject.references.should == [
        InternetMessage::MessageId.new('a.b@example.net'),
        InternetMessage::MessageId.new('c.d@example.com')
      ]
    end
    it '#subject returns String' do
      subject.subject.should == 'test'
    end
    it '#comments returns Array of String' do
      subject.comments.should == ['This is comment message.']
    end
    it '#keywords returns Array of String' do
      subject.keywords.should == ['hoge', 'fuga', 'foo', 'bar']
    end
    it '#resent_date returns Resent-Date in latest trace block as DateTime' do
      subject.resent_date.should == DateTime.new(2011, 9, 6, 19, 49, 42, '+0900')
    end
    it '#resent_from returns Resent-From in latest trace block as InternetMessage::Mailbox' do
      subject.resent_from.should == InternetMessage::Mailbox.new('hoge', 'example.com')
    end
    it '#resent_sender returns Resent-Sender in latest trace block as InternetMessage::Mailbox' do
      subject.resent_sender.should == InternetMessage::Mailbox.new('fuga', 'example.net')
    end
    it '#resent_to returns Resent-To in latest trace block as InternetMessage::Mailbox' do
      subject.resent_to.should be_kind_of Array
      subject.resent_to.size.should == 2
      subject.resent_to.each{|a| a.should be_kind_of InternetMessage::Mailbox}
    end
    it '#resent_cc returns Resent-Cc in latest trace block as InternetMessage::Mailbox' do
      subject.resent_cc.should be_kind_of Array
      subject.resent_cc.size.should == 1
      subject.resent_cc.each{|a| a.should be_kind_of InternetMessage::Mailbox}
    end
    it '#resent_bcc returns Resent-Bcc in latest trace block as InternetMessage::Mailbox' do
      subject.resent_bcc.should be_kind_of Array
      subject.resent_bcc.size.should == 1
      subject.resent_bcc.each{|a| a.should be_kind_of InternetMessage::Mailbox}
    end
    it '#resent_message_id returns Resent-Message-Id in latest trace block as InternetMessage::MessageId' do
      subject.resent_message_id.should == InternetMessage::MessageId.new('hoge.fuga@example.com')
    end
    it '#return_path returns Return-Path in latest trace block as InernetMessage::Address' do
      subject.return_path.should == InternetMessage::Address.new('hoge', 'example.com')
    end
    it '#received return Received in latest trace block as Array of InternetMessage::Received' do
      subject.received.should be_kind_of Array
      subject.received.size.should == 2
      subject.received.each{|a| a.should be_kind_of InternetMessage::Received}
    end
    it '#mime_version returns String' do
      subject.mime_version.should == '1.0'
    end
    it '#content_type returns ContentType' do
      subject.content_type.should == InternetMessage::ContentType.new('text', 'plain', 'charset'=>'UTF-8')
    end
    it '#content_transfer_encoding returns String' do
      subject.content_transfer_encoding.should == '7bit'
    end
    it '#content_id returns Content-Id as InternetMessage::MessageId' do
      subject.content_id.should == InternetMessage::MessageId.new('a.b@example.com')
    end
    it '#content_description returns String' do
      subject.content_description.should == 'Description of Contents'
    end
    it '#content_disposition return ContentDisposition' do
      subject.content_disposition.should == InternetMessage::ContentDisposition.new('inline', 'filename'=>'hoge.txt')
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

describe InternetMessage::TraceBlockList do
  let(:return_path){double :name=>'return-path'}
  let(:received){double :name=>'received'}
  let(:resent){double :name=>'resent-from'}
  context 'with one block' do
    before do
      subject.push return_path
      subject.push received
      subject.push received
      subject.push received
      subject.clean
    end
    its('blocks.size'){should == 1}
    its('blocks.first'){should == [return_path, received, received, received]}
  end
  context 'with many block' do
    before do
      subject.push return_path
      subject.push received
      subject.push return_path
      subject.push received
      subject.push received
      subject.clean
    end
    its('blocks.size'){should == 2}
    it{subject.blocks.first.should == [return_path, received]}
    it{subject.blocks[1].should == [return_path, received, received]}
  end
  context 'with many block without Return-Path' do
    before do
      subject.push received
      subject.push resent
      subject.push received
      subject.push received
      subject.clean
    end
    its('blocks.size'){should == 2}
    it{subject.blocks.first.should == [received, resent]}
    it{subject.blocks[1].should == [received, received]}
  end
end
