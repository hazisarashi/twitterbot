#coding: utf-8

require 'json'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'twitterbot'

config = JSON.load( open("config/config.json") )

Twitter.configure {|twitter_config|
  twitter_config.consumer_key       = config["twitter"]["consumer_key"]
  twitter_config.consumer_secret    = config["twitter"]["consumer_secret"]
  twitter_config.oauth_token        = config["twitter"]["oauth_token"]
  twitter_config.oauth_token_secret = config["twitter"]["oauth_token_secret"]
}

bot = TwitterBot.new
config["src_screen_names"].each do |screen_name|
  bot.study(screen_name)
end

# bot.reply_to_mentions unless ARGV.include?("-no-reply")
bot.tweet unless ARGV.include?("-no-tweet")