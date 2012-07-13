require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

require 'mmapscanner'

describe InternetMessage::HeaderField do
  subject{InternetMessage::HeaderField.parse(MmapScanner.new(src))}

  context 'Date' do
    let(:src){'Date: Sun, 8 Jul 2012 11:16:22 +0900'}
    its(:name){should == 'date'}
    its(:parse){should == DateTime.new(2012,7,8,11,16,22,'+0900')}
  end

  context 'Resent-Date' do
    let(:src){'Resent-Date: Sun, 8 Jul 2012 11:16:22 +0900'}
    its(:name){should == 'resent-date'}
    its(:parse){should == DateTime.new(2012,7,8,11,16,22,'+0900')}
  end

  context 'From' do
    let(:src){'From: TOMITA Masahiro <tommy@tmtm.org>, hoge@example.com'}
    its(:name){should == 'from'}
    its(:parse){should == [InternetMessage::Mailbox.new('tommy', 'tmtm.org', 'TOMITA Masahiro'), InternetMessage::Mailbox.new('hoge', 'example.com')]}
  end

  context 'Resent-From' do
    let(:src){'Resent-From: TOMITA Masahiro <tommy@tmtm.org>, hoge@example.com'}
    its(:name){should == 'resent-from'}
    its(:parse){should == [InternetMessage::Mailbox.new('tommy', 'tmtm.org', 'TOMITA Masahiro'), InternetMessage::Mailbox.new('hoge', 'example.com')]}
  end

  context 'Sender' do
    let(:src){'Sender: TOMITA Masahiro <tommy@tmtm.org>'}
    its(:name){should == 'sender'}
    its(:parse){should == InternetMessage::Mailbox.new('tommy', 'tmtm.org', 'TOMITA Masahiro')}
  end

  context 'Resent-Sender' do
    let(:src){'Resent-Sender: TOMITA Masahiro <tommy@tmtm.org>'}
    its(:name){should == 'resent-sender'}
    its(:parse){should == InternetMessage::Mailbox.new('tommy', 'tmtm.org', 'TOMITA Masahiro')}
  end

  context 'Message-Id' do
    let(:src){'Message-Id: <hoge@tmtm.org>'}
    its(:name){should == 'message-id'}
    its(:parse){should == InternetMessage::MessageId.new('hoge@tmtm.org')}
  end

  context 'Content-Id' do
    let(:src){'Content-Id: <hoge@tmtm.org>'}
    its(:name){should == 'content-id'}
    its(:parse){should == InternetMessage::MessageId.new('hoge@tmtm.org')}
  end

  context 'Resent-Message-Id' do
    let(:src){'Resent-Message-Id: <hoge@tmtm.org>'}
    its(:name){should == 'resent-message-id'}
    its(:parse){should == InternetMessage::MessageId.new('hoge@tmtm.org')}
  end

  context 'Mime-Version' do
    let(:src){'Mime-Version: 1.0'}
    its(:name){should == 'mime-version'}
    its(:parse){should == '1.0'}
  end

  context 'In-Reply-To' do
    let(:src){'In-Reply-To: <hoge@tmtm.org> <fuga@tmtm.org>'}
    its(:name){should == 'in-reply-to'}
    its(:parse){should == [InternetMessage::MessageId.new('hoge@tmtm.org'), InternetMessage::MessageId.new('fuga@tmtm.org')]}
  end

  context 'References' do
    let(:src){'References: <hoge@tmtm.org> <fuga@tmtm.org>'}
    its(:name){should == 'references'}
    its(:parse){should == [InternetMessage::MessageId.new('hoge@tmtm.org'), InternetMessage::MessageId.new('fuga@tmtm.org')]}
  end

  context 'Content-Transfer-Encoding' do
    let(:src){'Content-Transfer-Encoding: 7bit'}
    its(:name){should == 'content-transfer-encoding'}
    its(:parse){should == '7bit'}
  end

  context 'Content-Type' do
    let(:src){'Content-Type: text/plain; charset=iso-2022-jp'}
    its(:name){should == 'content-type'}
    its(:parse){should == InternetMessage::ContentType.new('text', 'plain', 'charset'=>'iso-2022-jp')}
  end

  context 'Content-Disposition' do
    let(:src){'Content-Disposition: attachment; filename=hoge.txt'}
    its(:name){should == 'content-disposition'}
    its(:parse){should == InternetMessage::ContentDisposition.new('attachment', 'filename'=>'hoge.txt')}
  end

  context 'Reply-To' do
    let(:src){'Reply-To: hoge@tmtm.org, group:;'}
    its(:name){should == 'reply-to'}
    its(:parse){should == [InternetMessage::Mailbox.new('hoge', 'tmtm.org'), InternetMessage::Group.new('group', [])]}
  end

  context 'To' do
    let(:src){'To: hoge@tmtm.org, group:;'}
    its(:name){should == 'to'}
    its(:parse){should == [InternetMessage::Mailbox.new('hoge', 'tmtm.org'), InternetMessage::Group.new('group', [])]}
  end

  context 'Cc' do
    let(:src){'Cc: hoge@tmtm.org, group:;'}
    its(:name){should == 'cc'}
    its(:parse){should == [InternetMessage::Mailbox.new('hoge', 'tmtm.org'), InternetMessage::Group.new('group', [])]}
  end

  context 'Bcc' do
    let(:src){'Bcc: hoge@tmtm.org, group:;'}
    its(:name){should == 'bcc'}
    its(:parse){should == [InternetMessage::Mailbox.new('hoge', 'tmtm.org'), InternetMessage::Group.new('group', [])]}
  end

  context 'Resent-To' do
    let(:src){'Resent-To: hoge@tmtm.org, group:;'}
    its(:name){should == 'resent-to'}
    its(:parse){should == [InternetMessage::Mailbox.new('hoge', 'tmtm.org'), InternetMessage::Group.new('group', [])]}
  end

  context 'Resent-Cc' do
    let(:src){'Resent-Cc: hoge@tmtm.org, group:;'}
    its(:name){should == 'resent-cc'}
    its(:parse){should == [InternetMessage::Mailbox.new('hoge', 'tmtm.org'), InternetMessage::Group.new('group', [])]}
  end

  context 'Resent-Bcc' do
    let(:src){'Resent-Bcc: hoge@tmtm.org, group:;'}
    its(:name){should == 'resent-bcc'}
    its(:parse){should == [InternetMessage::Mailbox.new('hoge', 'tmtm.org'), InternetMessage::Group.new('group', [])]}
  end

  context 'Keywords' do
    let(:src){'Keywords: hoge, fuga'}
    its(:name){should == 'keywords'}
    its(:parse){should == ['hoge', 'fuga']}
  end

  context 'Return-Path' do
    let(:src){'Return-Path: <hoge@example.com>'}
    its(:name){should == 'return-path'}
    its(:parse){should == InternetMessage::Address.new('hoge', 'example.com')}
  end

  context 'Received' do
    let(:src){'Received: from s3.tmtm.org (localhost [127.0.0.1]) by s2.tmtm.org (Postfix) with ESMTP id 2DD3CA3253 for <tommy@tmtm.org>; Mon,  9 Jul 2012 21:35:00 +0900 (JST)'}
    its(:name){should == 'received'}
    its(:parse){should == InternetMessage::Received.new('s3.tmtm.org', 's2.tmtm.org', nil, 'ESMTP', '2DD3CA3253', InternetMessage::Address.new('tommy', 'tmtm.org'), DateTime.new(2012,7,9,21,35,0,'+0900'))}
  end

  context 'Subject' do
    let(:src){'Subject: hoge fuga'}
    its(:name){should == 'subject'}
    its(:parse){should == 'hoge fuga'}
  end

  describe '.parse_mailboxlist:' do
    subject{InternetMessage::HeaderField.parse_mailboxlist(src, decode)}
    let(:src){'HOGE <hoge@example.com>, =?us-ascii?q?FUGA?= <fuga@example.com>'}

    context 'decode_mime_header is false' do
      let(:decode){false}
      it do
        should == [
          InternetMessage::Mailbox.new('hoge', 'example.com', 'HOGE'),
          InternetMessage::Mailbox.new('fuga', 'example.com', '=?us-ascii?q?FUGA?='),
        ]
      end
    end

    context 'decode_mime_header is true' do
      let(:decode){true}
      it do
        should == [
          InternetMessage::Mailbox.new('hoge', 'example.com', 'HOGE'),
          InternetMessage::Mailbox.new('fuga', 'example.com', 'FUGA'),
        ]
      end
    end
  end

  describe '.parse_addrlist:' do
    subject{InternetMessage::HeaderField.parse_addrlist(src, decode)}
    let(:src){'=?us-ascii?q?GROUP?=: member@example.com;, HOGE <hoge@example.com>, =?us-ascii?q?FUGA?= <fuga@example.com>'}

    context 'decode_mime_header is false' do
      let(:decode){false}
      it do
        should == [
          InternetMessage::Group.new('=?us-ascii?q?GROUP?=', [InternetMessage::Mailbox.new('member', 'example.com')]),
          InternetMessage::Mailbox.new('hoge', 'example.com', 'HOGE'),
          InternetMessage::Mailbox.new('fuga', 'example.com', '=?us-ascii?q?FUGA?='),
        ]
      end
    end

    context 'decode_mime_header is true' do
      let(:decode){true}
      it do
        should == [
          InternetMessage::Group.new('GROUP', [InternetMessage::Mailbox.new('member', 'example.com')]),
          InternetMessage::Mailbox.new('hoge', 'example.com', 'HOGE'),
          InternetMessage::Mailbox.new('fuga', 'example.com', 'FUGA'),
        ]
      end
    end
  end

  describe '.parse_keywords:' do
    subject{InternetMessage::HeaderField.parse_keywords(src, decode)}
    let(:src){'=?us-ascii?q?hoge?= fuga, hage'}
    context 'decode_mime_header is false' do
      let(:decode){false}
      it{should == ['=?us-ascii?q?hoge?= fuga', 'hage']}
    end
    context 'decode_mime_header is true' do
      let(:decode){true}
      it{should == ['hoge fuga', 'hage']}
    end
  end

  describe '.parse_return_path:' do
    subject{InternetMessage::HeaderField.parse_return_path(src)}
    context '<hoge@example.com>' do
      let(:src){'<hoge@example.com>'}
      it{should == InternetMessage::Address.new('hoge', 'example.com')}
    end
    context 'hoge@example.com' do
      let(:src){'hoge@example.com'}
      it{should == nil}
    end
    context '<hoge>' do
      let(:src){'<hoge>'}
      it{should == nil}
    end
  end
end

