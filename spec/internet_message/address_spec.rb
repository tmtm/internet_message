# -*- coding: utf-8 -*-
require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::Address do
  describe '#to_s' do
    let(:local_part){'hoge'}
    let(:domain){'example.com'}
    subject{InternetMessage::Address.new(local_part, domain)}
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

    context 'localpart including UTF-8 character' do
      let(:local_part){'あいう'}
      it 'quote localpart' do
        subject.to_s.should == '"あいう"@example.com'
      end
    end

  end

  describe '#==' do
    it 'is case-insensitive' do
      InternetMessage::Address.new('hoge','example.com').should == InternetMessage::Address.new('HOGE', 'EXAMPLE.COM')
    end
  end
end
