require 'cinch'

class Botsnack
  include Cinch::Plugin

  match /botsnack/, :use_prefix => false

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
