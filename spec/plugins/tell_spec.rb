require 'spec_helper'
require 'cinch/test'
require 'yaml'
require 'pp'

require './plugins/tell.rb'
require './lib/config.rb'
require './lib/storage.rb'

describe Tell do
  include Cinch::Test

  before(:each) do
    $config = Funkbot::Conf.new(YAML.load_file('./config/config.yaml'))
  end

  let!(:nick) { 'bob' }
  let!(:channel) { '#jibjib' }
  let!(:store) { double('Funkbot::Storage') }
  let!(:bot) { make_bot(Tell, store: store) }

  describe 'listen' do
    context 'receiving something' do
      let(:content) { 'hello' }
      before(:each) do
        allow(store).to receive(:has_key?).and_return(false)
      end
      it 'stays quiet' do
        message = make_message(bot, content, channel: channel, nick: nick)
        replies = get_replies(message)
        expect(replies).to be_empty
      end
    end
  end
end
