require 'spec_helper'
require 'cinch/test'
require 'yaml'
require 'pp'

require './plugins/factoid.rb'
require './lib/config.rb'
require './lib/storage.rb'

describe Factoid do
  include Cinch::Test

  before(:each) do
    $config = Funkbot::Conf.new(YAML.load_file('./config/config.yaml'))
  end

  let!(:nick) { 'melon' }
  let!(:channel) { '#jibjib' }
  let!(:store) { double('Funkbot::Storage') }
  let!(:bot) { make_bot(Factoid, store: store) }

  describe 'listen' do
    context 'when message doesn\'t end in a ?' do
      let(:content) { 'Hello World!' }
      it 'stays quiet' do
        message = make_message(bot, content, channel: channel, nick: nick)
        replies = get_replies(message)
        expect(replies).to be_empty
      end
    end

    context 'when message ends in a ?' do
      context 'when no fact' do
        let(:content) { 'cows' }
        before(:each) do
          allow(store).to receive(:has_key?).and_return(false)
        end
        it 'stays quiet' do
          message = make_message(bot, "#{content}?", channel: channel, nick: nick)
          replies = get_replies(message)
          expect(replies).to be_empty
        end
      end

      context 'when has a fact with single response' do
        let(:subject) { 'cows' }
        before(:each) do
          allow(store).to receive(:has_key?).and_return(true)
          allow(store).to receive(:[]).with(subject).and_return(['is foo'])
        end
        it 'should reply' do
          message = make_message(bot,"#{subject}?", channel: channel, nick: nick)
          replies = get_replies(message)
          expect(replies.first[:text]).to match /^.* #{subject} is foo$/
        end
      end

      context 'when has a fact with multiple responses' do
        let(:subject) { 'cows' }
        let(:facts) { ['is foo','are bah'] }
        before(:each) do
          allow(store).to receive(:has_key?).and_return(true)
          allow(store).to receive(:[]).with(subject).and_return(facts)
        end
        it 'should reply' do
          message = make_message(bot, "#{subject}?", channel: channel, nick: nick)
          replies = get_replies(message)
          expect(replies.first[:text]).to match /^.* #{subject} (#{facts.join('|')})$/
        end
      end
    end
  end
end
