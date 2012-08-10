#coding: utf-8

require 'twitter'
require 'twitterbot/markov'
require 'twitterbot/spliter'
require 'twitterbot/core_ext/string'

module TwitterBot
  class Client
    def initialize
      @bot_screen_name = Twitter.update_profile.screen_name
      @replied_users = Array.new
      @markov = Markov.new
      @markov_mention = Markov.new
      @spliter = Spliter.new
    end

    def build_tweet
      10.times do
        result = @markov.build.join('')
        return result if result.size <= 140 && result.size >= 4
      end
      raise StandardError.new('retly limit is exceeded')
    end

    def build_reply(screen_name)
      result = @markov_mention.build.join('')
      result = "@#{screen_name} #{result}"
      return result if result.size <= 140

      raise StandardError.new('retly limit is exceeded')
    end

    def study(screen_name)
      Twitter.user_timeline(screen_name, {
        "count" => 200,
      }).each {|status|
        removed = status.text.remove_uri
        splited = @spliter.split(removed)
        if status.text.is_mention?
          @markov_mention.study(splited)
        else
          @markov.study(splited)
        end
      }
      pp @markov.table if $debug
    end

    def reply_to_mentions
      Twitter.user_timeline(@bot_screen_name).each {|status|
        screen_name = status.in_reply_to_screen_name
        @replied_users << screen_name if screen_name
      }

      Twitter.mentions.each {|status|
        id = status.id
        screen_name = status.user.screen_name
        next if @replied_users.include?(screen_name) # リストにあるならリプライしない
        next if screen_name == @bot_screen_name      # 自身にはリプライしない
        result = build_reply(screen_name)
        Twitter.update(result, {
          "in_reply_to_status_id" => id,
        })
        @replied_users << screen_name # リプライ済リストに入れる
        puts "reply: #{result}"
      }
    end

    def tweet(tweet_text=nil)
      tweet_text = build_tweet unless tweet_text
      Twitter.update(tweet_text)
      puts "tweet(markov): #{tweet_text}"
    end
  end
end