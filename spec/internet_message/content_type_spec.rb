# -*- coding: utf-8 -*-
require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::ContentType do
  describe '.parse' do
    subject{InternetMessage::ContentType.parse(arg)}

    context 'with empty' do
      let(:arg){''}
      it{should == nil}
    end

    context 'without params' do
      let(:arg){'text/plain'}
      it 'attribute is empty' do
        subject.type.should == 'text'
        subject.subtype.should == 'plain'
        subject.attribute.should == {}
      end
    end

    context 'with params' do
      let(:arg){'text/plain; charset=iso-2022-jp'}
      it 'attribute is Hash' do
        subject.type.should == 'text'
        subject.subtype.should == 'plain'
        subject.attribute.should == {'charset'=>'iso-2022-jp'}
      end
    end

    context 'with upper case name' do
      let(:arg){'TEXT/PLAIN; CHARSET=ISO-2022-JP'}
      it 'type, subtype and attribute name are downcase' do
        subject.type.should == 'text'
        subject.subtype.should == 'plain'
        subject.attribute.should == {'charset'=>'ISO-2022-JP'}
      end
    end
  end

  describe '#==' do
    context 'same type, subtype and attribute' do
      it 'true' do
        a = InternetMessage::ContentType.parse('text/plain; charset=iso-2022-jp')
        b = InternetMessage::ContentType.new('text', 'plain', {'charset'=>'iso-2022-jp'})
        (a == b).should == true
      end
    end
  end
end

