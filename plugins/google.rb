require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'

class Google
  include Cinch::Plugin
  set plugin_name: "google", help: "google <query> - Search google for <query>"

  match /google (.+)/, use_prefix: false

  def self.search(query)
    url = "http://www.google.com/search?q=#{CGI.escape(query)}"
    res = Nokogiri::HTML(open(url)).at("h3.r")

    title = res.text
    link = res.at('a')[:href]
    link.sub!(/^\/url\?q=/, '')
    link.sub!(/&.*$/, '')

    CGI.unescape_html "#{title} : #{link}"
  rescue
    "No results found"
  end

  def execute(m, query)
    m.reply(self.class.search(query))
  end
end

