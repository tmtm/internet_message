require "#{File.dirname __FILE__}/../lib/internet_message"

describe 'InternetMessage' do
  subject{InternetMessage.new(src)}
  context 'with simple message' do
    let(:src){<<EOS}
Return-Path: <hoge@example.com>
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
    it '#message_id returns message-id String' do
      subject.message_id.should == '20101203223001.5C9523E3A70@note.tmtm.org'
    end
    it '#in_reply_to returns Array of String' do
      subject.in_reply_to.should == ['a.b@example.net', 'c.d@example.com']
    end
    it '#references returns Array of String' do
      subject.references.should == ['a.b@example.net', 'c.d@example.com']
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
    it '#resent_date'
    it '#resent_from'
    it '#resent_sender'
    it '#resent_to'
    it '#resent_cc'
    it '#resent_bcc'
    it '#resent_msg_id'
    it '#return_path'
    it '#received'
    it '#mime_version'
    it '#content_type returns ContentType' do
      subject.content_type.should == InternetMessage::ContentType.new('text', 'plain', 'charset'=>'UTF-8')
    end
    it '#content_transfer_encoding'
    it '#content_id'
    it '#content_description'
    it '#content_disposition'

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
