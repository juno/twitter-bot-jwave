require 'open-uri'
require 'redis'
require 'twitter_oauth'
require 'yaml'

module Jwave
  class Updater
    XML_URL = 'http://www.j-wave.co.jp/top/xml/now_on_air_song.xml'
    CACHE_KEY = 'jwave_cache'
    SLEEP_SECONDS = 60 * 2

    def self.run
      $stdout.sync = true
      $stdout.puts 'Starting...'
      updater = self.new
      loop do
        updater.update
        sleep(SLEEP_SECONDS)
      end
    rescue Interrupt => e
      $stderr.puts "Interrupt: #{e.message}"
    rescue SignalException => e
      $stderr.puts "Signal exception: #{e.message}"
    ensure
      $stdout.puts 'Exit'
    end

    def initialize
      uri = URI.parse(ENV['REDIS_URL'] || ENV['REDISTOGO_URL'])
      $stdout.puts "Connecting to Redis: #{uri}"
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    end

    def update
      cached_data = load_cache
      $stdout.puts 'Loading XML'
      last_modified, xml = load_xml
      if cached_data && !cached_data.expired?(last_modified)
        $stdout.puts 'Cache hit. Skip.'
        return
      end

      data = OnAirData.new(last_modified, xml)
      store_cache data
      $stdout.puts "Tweet message: #{data}"
      message = build_message(data)
      ENV["DRY_RUN"] != "" ? tweet(message) : $stdout.puts(message)
    rescue SocketError => e
      # ignore Name or service not known error
      $stderr.puts "SocketError: #{e.message}"
    rescue JSON::ParserError => e
      # ignore twitter error HTML
      $stderr.puts "JSON::ParseError: #{e.message}"
    end

    private

    # @return [OnAirData, nil]
    def load_cache
      value = @redis.get(CACHE_KEY)
      return nil unless value
      YAML.load(value)
    end

    # @return [Array]
    def load_xml
      last_modified = xml = ''
      open(XML_URL) do |f|
        last_modified = f.last_modified
        xml = f.readlines.join
      end
      [last_modified, xml]
    end

    # @param [OnAirData] data
    def store_cache(data)
      @redis.set(CACHE_KEY, YAML.dump(data))
    end

    # @param [String] message
    def tweet(message)
      t = TwitterOAuth::Client.new(consumer_key: ENV['TWITTER_CONSUMER_KEY'],
                                   consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
                                   token: ENV['TWITTER_TOKEN'],
                                   secret: ENV['TWITTER_SECRET'])
      t.update message
    end

    # @param [OnAirData] data
    # @return [String]
    def build_message(data)
      "#{data.information} #{data.url}"
    end
  end
end
