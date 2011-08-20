require __FILE__.sub(/\/spec\//, '/lib/').sub(/_spec\.rb\z/,'')

describe InternetMessage::Mailbox do
  describe '.parse' do
    it 'return Mailbox' do
      ret = InternetMessage::Mailbox.parse('display name <hoge@example.com>')
      ret.should be_kind_of InternetMessage::Mailbox
    end
  end
end

