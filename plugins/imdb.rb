require 'cinch'
require 'filmbuff'

class IMDb
  include Cinch::Plugin
  set :help, "!imdb <title> - Search for film <title>"

  match /imdb (.+)/i

  def self.search(title)
    @imdb = FilmBuff::IMDb.new
    # imdb.locale = config[:locale] if config[:locale]

    movie = @imdb.find_by_title(title)

    "#{movie.title} - #{movie.rating}/10 - http://www.imdb.com/title/#{movie.imdb_id}"
  end

  def execute(m, title)
    m.reply(self.class.search(title))
  end
end
