require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe 'InternetMessage::Received.parse' do
  subject{InternetMessage::Received.parse(src)}
  context 'with normal value' do
    let(:src){<<EOS}
from smtp.example.com (localhost [127.0.0.1])
	by smtp.example.net (Postfix) with ESMTP id 0ECC2108362
	for <tommy@example.net>; Thu,  1 Feb 2007 02:05:10 +0900 (JST)
EOS
    it 'return InternetMessage::Received' do
      subject.from.should == 'smtp.example.com'
      subject.by.should == 'smtp.example.net'
      subject.via.should be_nil
      subject.with.should == 'ESMTP'
      subject.id.should == '0ECC2108362'
      subject.for.should == InternetMessage::Address.new('tommy', 'example.net')
      subject.date.should == DateTime.new(2007,2,1,2,5,10,'+0900')
    end
  end
  context 'with invalid "by"' do
    let(:src){'from 223.128.78.240 by ; Wed, 31 Jan 2007 17:57:43 +0100'}
    it 'return InternetMessage::Received' do
      subject.from.should == '223.128.78.240'
      subject.by.should == nil
      subject.via.should be_nil
      subject.with.should == nil
      subject.id.should == nil
      subject.for.should == nil
      subject.date.should == DateTime.new(2007,1,31,17,57,43,'+0100')
    end
  end
  context 'with invalid "for", "date"' do
    let(:src){<<EOS}
from Infomarks Corporation (http://www.infomarks.co.jp/)
	by version 2.0.1.a with id UCT00000
	for <5-subscribers>; 
EOS
    it 'return InternetMessage::Received' do
      subject.from.should == 'Infomarks'
      subject.by.should == 'version'
      subject.via.should be_nil
      subject.with.should == 'id'
      subject.id.should == nil
      subject.for.should == nil
      subject.date.should == nil
    end
  end
end
