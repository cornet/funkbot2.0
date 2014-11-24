#!/usr/bin/env ruby

require 'yaml'
require 'cinch'
require './lib/config.rb'
require './lib/storage.rb'

Dir["./plugins/*.rb"].each {|file| require file }

$config = Funkbot::Conf.new(YAML.load_file("./config/config.yaml"))

funkbot = Cinch::Bot.new do
  configure do |c|
    c.server           = $config.bot.server
    c.port             = $config.bot.port
    c.password         = $config.bot.password
    c.nick             = $config.bot.nick
    c.channels         = $config.bot.channels
    c.verbose          = $config.bot.verbose
    c.plugins.plugins  = [Greeting,Botsnack,Tell,Factoid,IMDb,TweetUrl]
    c.plugins.prefix   = ""
    c.ssl.use          = $config.bot.ssl
    c.ssl.verify       = $config.bot.ssl_verify
  end
end

funkbot.start
