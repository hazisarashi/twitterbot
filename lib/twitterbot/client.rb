#coding: utf-8

require 'net/http'
require 'twitter'
require 'uri'
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

    def http_query(method, uri_str, query)
      uri = URI.parse(uri_str)
      query_string = query.map{|k,v| URI.encode(k) + "=" + URI.encode(v) }.join('&')
      Net::HTTP.start(uri.host, uri.port) {|http|
        if method == 'get'
          query_string = '?' + query_string unless query_string.empty?
          http.get(uri.path + query_string)
        else
          http.post(uri.path, query_string)
        end
      }
    end

    def build_tweet
      10.times do
        result = @markov.build.join('')
        return result if result.size <= 140 && result.size >= 4 # 140文字以内なら採用
      end
      raise StandardError.new('retly limit is exceeded')
    end

    def build_reply(screen_name)
      result = @markov_mention.build.join('')
      result = "@#{screen_name} #{result}"
      return result if result.size <= 140 # 140文字以内なら採用

      raise StandardError.new('retly limit is exceeded')
    end

    def study (screen_name)
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
      # リプライ済リストを取得
      Twitter.user_timeline(@bot_screen_name).each {|status|
        screen_name = status.in_reply_to_screen_name
        @replied_users << screen_name if screen_name
      }
      # reply
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