require 'cinch'

class Greeting
  include Cinch::Plugin

  match /^(hello|hi|ello|morning|afternoon|evening)(\W+.*|$)/i, use_prefix: false

  def execute(m)
    greetings = ['Hi', 'Hello',' Hola!']
    m.reply "#{greetings.sample} #{m.user.nick}"
  end

end
