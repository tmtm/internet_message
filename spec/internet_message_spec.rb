# -*- coding: utf-8 -*-
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
    it '#preamble returns nil' do
      subject.preamble.should == nil
    end
    it '#epilogue returns nil' do
      subject.epilogue.should == nil
    end
    it '#parts returns []' do
      subject.parts.should == []
    end
    it '#message returns nil' do
      subject.message.should == nil
    end
  end

  context 'with empty field value' do
    let(:src){<<EOS}
Return-Path:
Received:
Received:
Resent-Date:
Resent-From:
Resent-Sender:
Resent-To:
Resent-Cc:
Resent-Bcc:
Resent-Message-Id:
From:
Sender:
Reply-To:
To:
Cc:
Bcc:
Subject:
Content-Type:
Date:
Message-Id:
In-Reply-To:
References:
Comments:
Keywords:
Mime-Version:
Content-Transfer-Encoding:
Content-Id:
Content-Description:
Content-Disposition:

body test
EOS
    its(:date){should be_nil}
    its(:from){should be_nil}
    its(:sender){should be_nil}
    its(:reply_to){should == []}
    its(:to){should == []}
    its(:cc){should == []}
    its(:bcc){should == []}
    its(:message_id){should be_nil}
    its(:in_reply_to){should == []}
    its(:references){should == []}
    its(:subject){should == ''}
    its(:comments){should == ['']}
    its(:keywords){should == []}
    its(:resent_date){should be_nil}
    its(:resent_from){should be_nil}
    its(:resent_sender){should be_nil}
    its(:resent_to){should == []}
    its(:resent_cc){should == []}
    its(:resent_bcc){should == []}
    its(:resent_message_id){should be_nil}
    its(:return_path){should be_nil}
    its(:received){should == []}
    its(:mime_version){should be_nil}
    its(:content_type){should be_nil}
    its(:content_transfer_encoding){should be_nil}
    its(:content_id){should == nil}
    its(:content_description){should == ''}
    its(:content_disposition){should be_nil}
    its(:type){should == 'text'}
    its(:subtype){should == 'plain'}
    its(:charset){should == 'us-ascii'}
    its(:body){should == "body test\n"}
    its(:preamble){should be_nil}
    its(:epilogue){should be_nil}
    its(:parts){should == []}
    its(:message){should be_nil}
  end

  context 'with empty header' do
    let(:src){<<EOS}

body test
EOS
    its(:date){should be_nil}
    its(:from){should be_nil}
    its(:sender){should be_nil}
    its(:reply_to){should == []}
    its(:to){should == []}
    its(:cc){should == []}
    its(:bcc){should == []}
    its(:message_id){should be_nil}
    its(:in_reply_to){should == []}
    its(:references){should == []}
    its(:subject){should be_nil}
    its(:comments){should == []}
    its(:keywords){should == []}
    its(:resent_date){should be_nil}
    its(:resent_from){should be_nil}
    its(:resent_sender){should be_nil}
    its(:resent_to){should == []}
    its(:resent_cc){should == []}
    its(:resent_bcc){should == []}
    its(:resent_message_id){should be_nil}
    its(:return_path){should be_nil}
    its(:received){should == []}
    its(:mime_version){should be_nil}
    its(:content_type){should be_nil}
    its(:content_transfer_encoding){should be_nil}
    its(:content_id){should == nil}
    its(:content_description){should be_nil}
    its(:content_disposition){should be_nil}
    its(:type){should == 'text'}
    its(:subtype){should == 'plain'}
    its(:charset){should == 'us-ascii'}
    its(:body){should == "body test\n"}
    its(:preamble){should be_nil}
    its(:epilogue){should be_nil}
    its(:parts){should == []}
    its(:message){should be_nil}
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

  context 'with base64 encoding' do
    let(:src){<<EOS}
Content-Transfer-Encoding: Base64

MDEyMzQ1Njc4OUFCQ0RFRkdISUpLTE1OT1BRUlNUVVZXWFla
EOS
    it '#body returns decoded body' do
      subject.body.should == '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    end
  end

  context 'with quoted-printable encoding' do
    let(:src){<<EOS}
Content-Transfer-Encoding: Quoted-Printable

0123456789=
ABCDEFGHIJKLMNO=
=50=51=52=53=54=55=56=57=58=59=5A=
EOS
    it '#body returns decoded body' do
      subject.body.should == '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    end
  end

  context 'with :decode_mime_header=>true' do
    subject{InternetMessage.new(src, :decode_mime_header=>true)}
    context 'for ascii header' do
      let(:src){<<EOS}
From: TOMITA Masahiro <tommy@tmtm.org>
To: TOMITA Masahiro <tommy@tmtm.org>
Subject: test aiueo
Content-Description: test aiueo
Comments: test aiueo
Keywords: abc, def, ghi
EOS
      it 'parse header' do
        subject.from.display_name.should == 'TOMITA Masahiro'
        subject.to.first.display_name.should == 'TOMITA Masahiro'
        subject.subject.should == 'test aiueo'
        subject.content_description.should == 'test aiueo'
        subject.comments.should == ['test aiueo']
        subject.keywords.should == ['abc', 'def', 'ghi']
      end
    end
    context 'for encoded header' do
      let(:src){<<EOS}
From: =?ISO-2022-JP?B?GyRCJEgkXyQ/JF4kNSRSJG0bKEI=?= <tommy@tmtm.org>
To: =?ISO-2022-JP?B?GyRCJEgkXyQ/JF4kNSRSJG0bKEI=?= <tommy@tmtm.org>
Subject: =?ISO-2022-JP?B?GyRCJUYlOSVIGyhCIBskQiQiJCQkJiQoJCobKEI=?=
Content-Description: =?ISO-2022-JP?B?GyRCJUYlOSVIGyhCIBskQiQiJCQkJiQoJCobKEI=?=
Comments: =?ISO-2022-JP?B?GyRCJUYlOSVIGyhCIBskQiQiJCQkJiQoJCobKEI=?=
Keywords: =?UTF-8?B?44GC?=, =?UTF-8?B?44GE?=, =?UTF-8?B?44GG?=
EOS
      it 'decode mime header' do
        subject.from.display_name.should == 'とみたまさひろ'
        subject.to.first.display_name.should == 'とみたまさひろ'
        subject.subject.should == 'テスト あいうえお'
        subject.content_description.should == 'テスト あいうえお'
        subject.comments.should == ['テスト あいうえお']
        subject.keywords.should == ['あ', 'い', 'う']
      end
    end
  end

  context 'with RFC2231' do
    subject{InternetMessage.new(src)}
    context 'splited parameter' do
      let(:src){<<EOS}
Content-Disposition: attachment;
 filename*0="hoge";
 filename*1="hoge.txt"
EOS
      it 'parameter is decoded' do
        subject.content_disposition.attribute['filename'].should == 'hogehoge.txt'
      end
    end
    context 'extended parameter' do
      let(:src){<<EOS}
Content-Disposition: attachment;
 filename*=us-ascii'en-us'This%20is%20%2A%2A%2Afun%2A%2A%2A
EOS
      it 'parameter is decoded' do
        subject.content_disposition.attribute['filename'].should == 'This is ***fun***'
      end
    end
    context 'complex parameter' do
      let(:src){<<EOS}
Content-Type: application/x-stuff;
 title*0*=us-ascii'en'This%20is%20even%20more%20;
 title*1*=%2A%2A%2Afun%2A%2A%2A%20;
 title*2="isn't it!"
EOS
      it 'parameter is decoded' do
        subject.content_type.attribute['title'].should == "This is even more ***fun*** isn't it!"
      end
    end
  end

  context 'with message/* type' do
    let(:src){<<EOS}
Content-Type: message/rfc822

From: TOMITA Masahiro <tommy@tmtm.org>
Subject: test

body
EOS
    it '.message returns InternetMessage' do
      m = subject.message
      m.from.should == InternetMessage::Mailbox.new('tommy', 'tmtm.org', 'TOMITA Masahiro')
      m.subject.should == 'test'
      m.body.should == "body\n"
    end
  end
end

describe 'InternetMessage.decode_mime_header_str' do
  subject{InternetMessage.decode_mime_header_str(src)}
  context 'with "=?ISO-8859-1?Q?a?="' do
    let(:src){'=?ISO-8859-1?Q?a?='}
    it{should == 'a'}
  end
  context 'with "=?ISO-8859-1?Q?a?= b"' do
    let(:src){'=?ISO-8859-1?Q?a?= b'}
    it{should == 'a b'}
  end
  context 'with "=?ISO-8859-1?Q?a?= =?ISO-8859-1?Q?b?="' do
    let(:src){'=?ISO-8859-1?Q?a?= =?ISO-8859-1?Q?b?='}
    it{should == 'ab'}
  end
  context 'with "=?ISO-8859-1?Q?a?=  =?ISO-8859-1?Q?b?="' do
    let(:src){'=?ISO-8859-1?Q?a?=  =?ISO-8859-1?Q?b?='}
    it{should == 'ab'}
  end
  context 'with "=?ISO-8859-1?Q?a?=\r\n =?ISO-8859-1?Q?b?="' do
    let(:src){"=?ISO-8859-1?Q?a?=\r\n =?ISO-8859-1?Q?b?="}
    it{should == 'ab'}
  end
  context 'with "=?ISO-8859-1?Q?a_b?="' do
    let(:src){'=?ISO-8859-1?Q?a_b?='}
    it{should == 'a b'}
  end
  context 'with "=?ISO-8859-1?Q?a?= =?ISO-8859-2?Q?_b?="' do
    let(:src){'=?ISO-8859-1?Q?a?= =?ISO-8859-2?Q?_b?='}
    it{should == 'a b'}
  end
end

describe 'InternetMessage.decode_mime_header_words' do
  subject{InternetMessage.decode_mime_header_words(InternetMessage::Tokenizer.new(src).tokenize)}
  context 'with "=?ISO-8859-1?Q?a?="' do
    let(:src){'=?ISO-8859-1?Q?a?='}
    it{should == 'a'}
  end
  context 'with "=?ISO-8859-1?Q?a?= b"' do
    let(:src){'=?ISO-8859-1?Q?a?= b'}
    it{should == 'a b'}
  end
  context 'with "=?ISO-8859-1?Q?a?= =?ISO-8859-1?Q?b?="' do
    let(:src){'=?ISO-8859-1?Q?a?= =?ISO-8859-1?Q?b?='}
    it{should == 'ab'}
  end
  context 'with "=?ISO-8859-1?Q?a?=  =?ISO-8859-1?Q?b?="' do
    let(:src){'=?ISO-8859-1?Q?a?=  =?ISO-8859-1?Q?b?='}
    it{should == 'ab'}
  end
  context 'with "=?ISO-8859-1?Q?a?=\r\n =?ISO-8859-1?Q?b?="' do
    let(:src){"=?ISO-8859-1?Q?a?=\r\n =?ISO-8859-1?Q?b?="}
    it{should == 'ab'}
  end
  context 'with "=?ISO-8859-1?Q?a_b?="' do
    let(:src){'=?ISO-8859-1?Q?a_b?='}
    it{should == 'a b'}
  end
  context 'with "=?ISO-8859-1?Q?a?= =?ISO-8859-2?Q?_b?="' do
    let(:src){'=?ISO-8859-1?Q?a?= =?ISO-8859-2?Q?_b?='}
    it{should == 'a b'}
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
