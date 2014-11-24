require 'spec_helper'
require 'cinch/test'
require 'yaml'
require 'pp'

require './plugins/tweet_url.rb'
require './lib/config.rb'

describe TweetUrl do
  include Cinch::Test

  before(:each) do
    $config = Funkbot::Conf.new(YAML.load_file('./config/config.yaml'))
  end

  describe 'reading a message' do
    describe 'with a commented URL' do
      it 'should tweet the URL with the comment and respond to the channel' do
        msg_url = 'http://www.kittenwar.com/'
        tw_url  = 'http://twitter.com/user/status'
        comment = 'kittens!'
        nick    = 'melon'
        tweet   = "#{msg_url}\n\n#{comment} (#{nick})"
        channel = 'jibjib'

        twitter_class    = double('Twitter::REST::Client')
        twitter_instance = double('twitter client')
        twitter_post     = double('twitter post')

        allow(twitter_class).to receive(:new).and_return(twitter_instance)
        expect(twitter_instance).to receive(:update) { tweet }.and_return(twitter_post)
        expect(twitter_post).to receive(:url).and_return(tw_url)

        bot = make_bot(TweetUrl, client: twitter_class)

        message = make_message(bot,
                               "#{msg_url} # #{comment}",
                               :channel => channel, :nick => nick)

        replies = get_replies(message)
        expect(replies.first.text).to match(%r{#{msg_url}\s+posted at\s+#{tw_url}})
      end
    end
  end
end
