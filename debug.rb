#coding: utf-8

require 'json'
require 'optparse'
require "pp"

$:.unshift(File.dirname(__FILE__) + "/lib")
require 'twitterbot'

config = JSON.load( open("config/config.json") )
Twitter.configure {|twitter_config|
  twitter_config.consumer_key       = config["twitter"]["consumer_key"]
  twitter_config.consumer_secret    = config["twitter"]["consumer_secret"]
  twitter_config.oauth_token        = config["twitter"]["oauth_token"]
  twitter_config.oauth_token_secret = config["twitter"]["oauth_token_secret"]
}


# Options
OptionParser.new do |opt|
    opt.on('--study [src_screen_names]') do |v|
      bot = TwitterBot.new
      $debug=true
      bot.study(v || config["src_screen_names"][0])
    end
    opt.on('--filter [src_screen_names]') do |v|
      # あとで書く
    end
    opt.parse(ARGV)
end