require 'cinch'
require 'twitter'

class TweetUrl
  include Cinch::Plugin

  def initialize(*args)
    super
    client = config[:client] || Twitter::REST::Client
    @twitter = client.new do |c|
      c.consumer_key        = $config.twitter.consumer_key
      c.consumer_secret     = $config.twitter.consumer_secret
      c.access_token        = $config.twitter.access_token
      c.access_token_secret = $config.twitter.access_secret
    end
  end

  set :help, "Tweets annotated URLs"

  match %r{^(https?://.*?)\s+#\s+(.*)}, :use_prefix => false

  def execute(m, url, comment)
    reply = tweet(m.user.nick, url, comment)
    m.reply(reply)
  end

  private

  def tweet(nick, url, comment)
    begin
      tweet = @twitter.update("#{url}\n\n#{comment} (#{nick})")
      reply = "#{url} posted at #{tweet.url}"
    rescue Twitter::Error => e
      reply = "Twitter sadness: #{e}"
    end

    reply
  end

end
