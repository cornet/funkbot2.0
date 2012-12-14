require 'cinch'

class Factoid
  include Cinch::Plugin

  def initialize(*args)
    super
    @store = Funkbot::Storage.new('factoid')
  end

  listen_to :message
  match /(.+?) is (.+)/,      method: :add_factoid
  match /(.+?) is also (.+)/, method: :save_factoid
  match /forget (.+)/,        method: :delete_factoid

  def listen(m)
    if m.message =~ /(.*)\?/
      prefixes = ['iirc,', 'hum... I think', 'Maybe', 'well, duh.']

      if @store.has_key? $1
        fact = @store[$1].sample
        if fact =~ /<reply>(.*)/
          m.channel.action $1
        else
          m.reply "#{prefixes.sample} #{$1} is #{fact}"
        end
      end

    end
  end

  def add_factoid(m, item, fact)
    # Ignore if "is also" since this method will fire in that case
    if fact =~ /also /
      return nil
    end

    if @store.has_key? item
      m.reply "But #{item} is #{@store[item].join(' or ')}"
    else
      add_or_update_fact(item, fact)
      m.reply 'ok'
    end
  end

  def save_factoid(m, item, fact)
    add_or_update_fact(item, fact)
    m.reply 'ok'
  end

  private
  def add_or_update_fact(item, fact)
    if @store.has_key?(item)
      facts = @store[item]
      facts << fact
      # Don't duplcate facts when adding
      @store[item] = facts.uniq
    else 
      @store[item] = [fact]
    end
  end
end
