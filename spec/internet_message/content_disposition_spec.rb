# -*- coding: utf-8 -*-
require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::ContentDisposition do
  describe '.parse' do
    subject{InternetMessage::ContentDisposition.parse(arg)}

    context 'with empty' do
      let(:arg){''}
      it{should == nil}
    end

    context 'without params' do
      let(:arg){'inline'}
      it 'attribute is empty' do
        subject.type.should == 'inline'
        subject.attribute.should == {}
      end
    end

    context 'with params' do
      let(:arg){'inline; filename=hoge'}
      it 'attribute is Hash' do
        subject.type.should == 'inline'
        subject.attribute.should == {'filename'=>'hoge'}
      end
    end

    context 'with upper case name' do
      let(:arg){'INLINE; FILENAME=HOGE'}
      it 'type and attribute name are downcase' do
        subject.type.should == 'inline'
        subject.attribute.should == {'filename'=>'HOGE'}
      end
    end
  end

  describe '#==' do
    context 'same type and attribute' do
      it 'true' do
        a = InternetMessage::ContentDisposition.parse('inline; filename="hoge"')
        b = InternetMessage::ContentDisposition.new('inline', {'filename'=>'hoge'})
        (a == b).should == true
      end
    end
  end
end
