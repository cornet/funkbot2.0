require 'cinch'

class Botsnack
  include Cinch::Plugin

  set :prefix, lambda{ |m| Regexp.new("^|" + Regexp.escape(m.bot.nick + ": " ))}
  match /botsnack/

  def execute(m)
    replies  = ['yay', ':)', '<reply>beams','<reply>smiles']

    reply = replies.sample
    if reply =~ /<reply>(.*)/
      m.channel.action $1
    else
      m.reply reply
    end
  end

end
