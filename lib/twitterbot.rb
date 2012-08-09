#coding: utf-8

require 'twitterbot/crawler'

module TwitterBot
  BEGIN_DELIMITER = '__BEGIN__'
  END_DELIMITER = '__END__'
  IGO_DIC_DIRECTORY = './ipadic' # 辞書ファイルがあるディレクトリを指定

  class << self
    def new(*args, &block)
      TwitterBot::Crawler.new(*args, &block)
    end

  private

    def method_missing(method, *args, &block)
      new.send(method, *args, &block)
    end

  end
end