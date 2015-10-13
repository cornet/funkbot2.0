require 'cinch'

class Botsnack
  include Cinch::Plugin

  set :help, "give the bot a botsnack"

  match /botsnack/, :use_prefix => true

  def execute(m)
    replies  = ['yay', ':)', '<reply>beams','<reply>smiles']

    reply = replies.sample
    if reply =~ /<reply>(.*)/
      m.channel.action $1
      m.reply 
    else
      m.reply reply
    end
  end

end
