require 'spec_helper'
require 'cinch/test'
require 'yaml'
require 'pp'

require './plugins/greeting.rb'
require './lib/config.rb'
require './lib/storage.rb'

describe Greeting do
  include Cinch::Test

  let!(:nick) { 'bob' }
  let!(:channel) { '#jibjib' }
  let!(:store) { double('Funkbot::Storage') }
  let!(:greetings) { ["Hi #{nick}","Hello #{nick}","Hola! #{nick}"] }
  let!(:bot) { make_bot(Greeting) }

  describe 'listen' do
    context 'when receives a just greeting message' do
      let(:content) { 'hello' }
      it 'replies with a greeting' do
        message = make_message(bot, content, channel: channel, nick: nick)
        replies = get_replies(message)
        expect(greetings).to include(replies.first[:text])
      end
    end

    context 'when receiving a message starting with a greeting' do
      let(:content) { 'hello foo' }
      it 'replies with a greeting' do
        message = make_message(bot, content, channel: channel, nick: nick)
        replies = get_replies(message)
        expect(greetings).to include(replies.first[:text])
      end
    end

    context 'when receiving a non-greeting message' do
      let(:content) { 'foo' }
      it 'doesn\'t reply' do
        message = make_message(bot, content, channel: channel, nick: nick)
        replies = get_replies(message)
        expect(replies).to be_empty
      end
    end

    context 'when that doesn\t start with a greeting' do
      let(:content) { 'why hello' }
      it 'doesn\'t reply' do
        message = make_message(bot, content, channel: channel, nick: nick)
        replies = get_replies(message)
        expect(replies).to be_empty
      end
    end
  end
end
