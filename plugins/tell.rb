require 'cinch'

class Tell
  include Cinch::Plugin

  def initialize(*args)
    super
    @store = config[:store]
  end

  listen_to :message
  match /tell (.+?) (.+)/, use_prefix: true

  def listen(m)
    if @store.has_key?(m.user.nick)
      @store[m.user.nick].each do |msg|
        m.reply "Hi #{m.user.nick}, #{msg['nick']} wanted you to know the following: #{msg['message']}"
      end
      @store.delete(m.user.nick)
    end
  end

  def execute(m, nick, message)
    save_message(m.user.nick, nick, message)
    m.user.send "OK #{m.user.nick}, next time I see #{nick} around, I'll tell them that"
  end

  private
  def save_message(from, to, message)
    if @store.has_key?(to)
      msgs = @store[to]
      msgs << {'nick' => from, 'message' => message}
      @store[to] = msgs
    else 
      @store[to] = [{'nick' => from, 'message' => message}]
    end
  end
end
