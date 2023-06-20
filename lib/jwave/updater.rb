# frozen_string_literal: true

require "open-uri"
require "redis"
require "yaml"

require_relative "twitter"

module Jwave
  # Tweet updater
  class Updater
    XML_URL = "https://www.j-wave.co.jp/top/xml/now_on_air_song_v2.xml"
    CACHE_KEY = "jwave_cache"
    SLEEP_SECONDS = 60 * 15

    def self.run
      $stdout.sync = true
      $stdout.puts "Starting..."
      updater = new
      loop do
        updater.update
        sleep(SLEEP_SECONDS)
      end
    rescue Interrupt => e
      warn "Interrupt: #{e.message}"
    rescue SignalException => e
      warn "Signal exception: #{e.message}"
    ensure
      $stdout.puts "Exit"
    end

    def initialize
      uri = URI.parse(ENV["REDIS_URL"] || ENV["REDISTOGO_URL"])
      $stdout.puts "Connecting to Redis: #{uri}"
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    end

    def update
      cached_data = load_cache
      $stdout.puts "Loading XML"
      last_modified, xml = load_xml
      if cached_data && !cached_data.expired?(last_modified)
        $stdout.puts "Cache hit. Skip."
        return
      end

      data = OnAirData.new(last_modified, xml)
      store_cache data
      $stdout.puts "Tweet message: #{data}"
      message = build_message(data)
      #if ENV["DRY_RUN"] == ""
        tweet(message)
      # else
      #   $stdout.puts "[Dry run]"
      #   $stdout.puts(message)
      # end
    rescue SocketError => e
      # ignore Name or service not known error
      warn "SocketError: #{e.message}"
    rescue JSON::ParserError => e
      # ignore twitter error HTML
      warn "JSON::ParseError: #{e.message}"
    end

    private

    # @return [OnAirData, nil]
    def load_cache
      value = @redis.get(CACHE_KEY)
      return nil unless value

      YAML.unsafe_load(value)
    end

    # @return [Array]
    def load_xml
      last_modified = xml = ""
      URI.open(XML_URL) do |f|
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
      response = Twitter.tweet(message)
      $stdout.puts "Tweet response: #{response.inspect}"
    end

    # @param [OnAirData] data
    # @return [String]
    def build_message(data)
      "#{data.information} #{data.url}"
    end
  end
end
