# -*- coding: utf-8 -*-
require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::ContentAttribute do
  describe '.parse_attribute' do
    subject{InternetMessage::ContentAttribute.parse_attribute(args)}
    def double_token(args)
      args.map{|a| double(:value=>a)}
    end

    context 'with valid args' do
      let(:args){
        double_token %w(; attr = value ; hoge = fuga)
      }
      it{should == {'attr'=>'value', 'hoge'=>'fuga'}}
    end

    context 'with invalid args' do
      let(:args){
        double_token %w(; attr = value ; hoge)
      }
      it{should == {'attr'=>'value'}}
    end

    context 'with empty args' do
      let(:args){[]}
      it{should == {}}
    end

    context 'RFC2231 pattern 1' do
      let(:args){
        double_token %w(; URL*0 = ftp:// ; URL*1 = cs.utk.edu/pub/moore/bulk-mailer/bulk-mailer.tar)
      }
      it{should == {'url'=>'ftp://cs.utk.edu/pub/moore/bulk-mailer/bulk-mailer.tar'}}
    end

    context 'RFC2231 pattern 2' do
      let(:args){
        double_token %w(; title* = us-ascii'en-us'This%20is%20%2A%2A%2Afun%2A%2A%2A)
      }
      it{should == {'title'=>'This is ***fun***'}}
    end

    context 'RFC2231 pattern 3' do
      let(:args){
        double_token %w(; title*0* = us-ascii'en'This%20is%20even%20more%20
                        ; title*1* = %2A%2A%2Afun%2A%2A%2A%20
                        ; title*2 = isn't\ it!)
      }
      it{should == {'title'=>"This is even more ***fun*** isn't it!"}}
    end

    context 'RFC2231 UTF-8 japanese' do
      let(:args){
        double_token %w(; name* = utf-8'ja'%E3%81%82%E3%81%84%E3%81%86%E3%81%88%E3%81%8A)
      }
      it{should == {'name'=>'あいうえお'}}
    end

    context 'RFC2231 invalid' do
      let(:args) {
        double_token %w(; name* = hogehoge)
      }
      it{should == {'name'=>'hogehoge'}}
    end
  end
end
