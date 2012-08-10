#coding: utf-8

module TwitterBot
  class Markov
    def initialize()
      @table = Array.new
    end
    attr_reader :table

    def study(words)
      return if words.size < 3
      for i in 0..(words.size - 3) do
        @table << [words[i], words[i + 1], words[i + 2]]
      end
    end

    def search1(key)
      array = Array.new
      @table.each {|row|
        array << row[1] if row[0] == key
      }
      array.sample
    end

    def search2(key1, key2)
      array = Array.new
      @table.each {|row|
        array << row[2] if row[0] == key1 && row[1] == key2
      }
      array.sample
    end

    def build
      array = Array.new
      key1 = BEGIN_DELIMITER
      key2 = search1(key1)
      while key2 != END_DELIMITER do
        array << key2
        value = search2(key1, key2)
        key1 = key2
        key2 = value
      end
      array
    end
  end
end