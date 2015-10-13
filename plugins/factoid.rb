require 'cinch'

class Factoid
  include Cinch::Plugin

  def initialize(*args)
    super
    @store = config[:store]
  end

  listen_to :message
  match /^(.+?) (is|are) (.+)/,       method: :add_factoid, use_prefix: true
  match /^(.+?) (is|are) also (.+)/,  method: :save_factoid, use_prefix: true
  match /^forget (.+)/,               method: :delete_factoid, use_prefix: true
  match /^literal (.*)\?/,            method: :show_factoid, use_prefix: true

  def listen(msg)
    msg.message.sub!(/^#{msg.bot.nick}:\s*/, '')
    if msg.message =~ /(.*)\?/
      prefixes = ['iirc,', 'hum... I think', 'Maybe', 'well, duh.']

      key = $1

      if @store.has_key? key
        fact = @store[key].sample
        if fact =~ /<reply>(.*)/
          msg.channel.action $1
        else
          msg.reply "#{prefixes.sample} #{key} #{fact}"
        end
      end

    end
  end

  def add_factoid(msg, item, type, fact)
    return nil if msg.action?

    # Ignore if "is also" since this method will fire in that case
    if fact =~ /also /
      return nil
    end

    item.sub!(/^#{msg.bot.nick}:\s*/, '')

    if @store.has_key? item
      msg.reply "But #{item} #{@store[item].sample}"
    else
      add_or_update_fact(item, "#{type} #{fact}")
    end
  end

  def show_factoid(msg, item)
    return nil if msg.action?

    if @store.has_key? item
      msg.reply "#{item} is #{@store[item].join(' or ')}"
    else
      msg.reply "I know nothing about #{item}"
    end
  end

  def save_factoid(msg, item, type, fact)
    return nil if msg.action?

    item.sub!(/^#{msg.bot.nick}:\s*/, '')
    add_or_update_fact(item, "#{type} #{fact}")
  end

  def delete_factoid(msg, item)
    return nil if msg.action?

    item.sub!(/^#{msg.bot.nick}:\s*/, '')
    if @store.has_key?(item)
      @store.delete(item)
      msg.reply "I've forgotton all about #{item}"
    end
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
