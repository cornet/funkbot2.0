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
    c.plugins.plugins  = [Greeting,Botsnack,Tell,Factoid,IMDb]
    c.plugins.prefix   = ""
    c.ssl.use          = $config.bot.ssl
    c.ssl.verify       = $config.bot.ssl_verify

    # Plugin Options
    c.plugins.options[Factoid] = {
      store: Funkbot::Storage.new('factoid',{
        :adapter => 'mysql2',
        :host => $config.bot.db_host,
        :user => $config.bot.db_user,
        :password => $config.bot.db_pass,
        :database => $config.bot.db_database
      })
    }
  end
end

funkbot.start
