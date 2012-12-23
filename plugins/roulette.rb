require 'cinch'

class Roulette
  include Cinch::Plugin

  set plugin_name: 'roulette', help: 'roulette [reload] - Take your turn with the gun'

  match /^roulette\??$/,        method: :shoot
  match /^roulette reload$/, method: :reload

  def initialize(*args)
    super
    @store = Funkbot::Storage.new('roulette')
  end

  def reload(m)
    chamber = Array.new(6, false)
    chamber[rand(6)] = true
    @store[m.channel.name] = chamber
    m.reply "Gun reloaded. You feeling lucky ?"
  end

  def shoot(m)
    if @store.has_key? m.channel.name
      chamber = @store[m.channel.name]
      m.reply chamber.shift ? 'Bang!' : 'Click!'
      @store[m.channel.name] = chamber
    else
      reload(m)
    end
  end
end
