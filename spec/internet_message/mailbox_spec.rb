require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::Mailbox do
  describe '.parse' do
    subject{InternetMessage::Mailbox.parse(src)}

    shared_examples_for 'hoge.fuga@example.com' do
      its(:local_part){should == 'hoge.fuga'}
      its(:domain){should == 'example.com'}
    end

    context "for 'hoge.fuga@example.com'" do
      let(:src){'hoge.fuga@example.com'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context "for 'hoge.fuga@example.com (comment)'" do
      let(:src){'hoge.fuga@example.com (comment)'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context "for '<hoge.fuga@example.com> (comment)'" do
      let(:src){'<hoge.fuga@example.com> (comment)'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context "for 'hoge(a).fuga(b)@(c)example.com(d)'" do
      let(:src){'hoge(a).fuga(b)@(c)example.com(d)'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context "for '\"hoge.fuga\"@example.com'" do
      let(:src){'"hoge.fuga"@example.com'}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context "for ' hoge . fuga @  example .  com '" do
      let(:src){' hoge . fuga @  example .  com '}
      it_should_behave_like 'hoge.fuga@example.com'
    end

    context "for 'hoge..fuga.@example..com'" do
      let(:src){'hoge..fuga.@example..com'}
      its(:local_part){should == 'hoge..fuga.'}
      its(:domain){should == 'example..com'}
    end

    context "for '@example.com'" do
      let(:src){'@example.com'}
      its(:local_part){should == ''}
      its(:domain){should == 'example.com'}
    end

    context "for 'hoge.fuga@'" do
      let(:src){'hoge.fuga@'}
      its(:local_part){should == 'hoge.fuga'}
      its(:domain){should == ''}
    end

    context "for 'display <hoge.fuga@example.com>'" do
      let(:src){'display <hoge.fuga@example.com>'}
      it_should_behave_like 'hoge.fuga@example.com'
      its(:display_name){should == 'display'}
    end
  end

  describe '.parse_list' do
    subject{InternetMessage::Mailbox.parse_list(src)}

    context "for 'hoge.fuga@example.com, foo.bar@example.net'" do
      let(:src){'hoge.fuga@example.com, foo.bar@example.net'}
      it {should == [
          InternetMessage::Mailbox.new('hoge.fuga', 'example.com'),
          InternetMessage::Mailbox.new('foo.bar', 'example.net'),
        ]
      }
    end

    context "for '\"hoge,fuga\" <hoge.fuga@example.com>, \"foo,bar\" <foo.bar@example.net>'" do
      let(:src){'"hoge,fuga" <hoge.fuga@example.com>, "foo,bar" <foo.bar@example.net>'}
      it {should == [
          InternetMessage::Mailbox.new('hoge.fuga', 'example.com', 'hoge,fuga'),
          InternetMessage::Mailbox.new('foo.bar', 'example.net', 'foo,bar'),
        ]
      }
    end

    context "for ',hoge.fuga@example.com,,, foo.bar@example.net,'" do
      let(:src){',hoge.fuga@example.com,,, foo.bar@example.net,'}
      it {should == [
          InternetMessage::Mailbox.new('hoge.fuga', 'example.com'),
          InternetMessage::Mailbox.new('foo.bar', 'example.net'),
        ]
      }
    end
  end

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

