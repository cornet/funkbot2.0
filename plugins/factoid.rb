require 'cinch'

class Factoid
  include Cinch::Plugin

  def initialize(*args)
    super
    @store = Funkbot::Storage.new('factoid',{
      :adapter => 'mysql2',
      :host => $config.bot.db_host,
      :user => $config.bot.db_user, 
      :password => $config.bot.db_pass,
      :database => $config.bot.db_database})
  end

  listen_to :message
  match /(.+?) (is|are) (.+)/,       method: :add_factoid, use_prefix: false
  match /(.+?) (is|are) also (.+)/,  method: :save_factoid, use_prefix: false
  match /forget (.+)/,               method: :delete_factoid, use_prefix: false
  match /literal (.*)\?/,            method: :show_factoid, use_prefix: false

  def listen(m)
    m.message.sub!(/^#{$config.bot.nick}:\s*/, '')
    if m.message =~ /(.*)\?/
      prefixes = ['iirc,', 'hum... I think', 'Maybe', 'well, duh.']

      key = $1

      if @store.has_key? key
        fact = @store[key].sample
        if fact =~ /<reply>(.*)/
          m.channel.action $1
        else
          m.reply "#{prefixes.sample} #{key} #{fact}"
        end
      end

    end
  end

  def add_factoid(m, item, type, fact)
    # Ignore if "is also" since this method will fire in that case
    if fact =~ /also /
      return nil
    end

    item.sub!(/^#{$config.bot.nick}:\s*/, '')

    if @store.has_key? item
      m.reply "But #{item} #{@store[item].join(' or ')}"
    else
      add_or_update_fact(item, "#{type} #{fact}")
    end
  end

  def show_factoid(m, item)
    if @store.has_key? item
      m.reply "#{item} is #{@store[item].join(' or ')}"
    else
      m.reply "I know nothing about #{item}"
    end
  end

  def save_factoid(m, item, type, fact)
    item.sub!(/^#{$config.bot.nick}:\s*/, '')
    add_or_update_fact(item, "#{type} #{fact}")
  end

  def delete_factoid(m, item)
    item.sub!(/^#{$config.bot.nick}:\s*/, '')
    if @store.has_key?(item)
      @store.delete(item)
      m.reply "I've forgotton all about #{item}"
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
