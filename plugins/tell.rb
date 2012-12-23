require 'cinch'

class Tell
  include Cinch::Plugin

  def initialize(*args)
    super
    @store = Funkbot::Storage.new('tell')
  end

  set prefix: ""

  listen_to :message
  match /tell (.+?) (.+)/

  def listen(m)
    if @store.has_key?(m.user.nick)
      @store[m.user.nick].each do |msg|
        m.reply "Hi #{m.user.nick}, #{msg['nick']} wanted you to know the following: #{msg['message']}"
      end
      @store.delete(m.user.nick)
    end
  end

  def execute(m, nick, message)
    save_message(nick, message)
    m.user.send "OK #{m.user.nick}, next time I see #{nick} around, I'll tell them that"
  end

  private
  def save_message(nick, message)
    if @store.has_key?(nick)
      msgs = @store[nick]
      msgs << {'nick' => nick, 'message' => message}
      @store[nick] = msgs
    else 
      @store[nick] = [{'nick' => nick, 'message' => message}]
    end
  end
end
