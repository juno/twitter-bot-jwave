require 'open-uri'
require 'twitter_oauth'
require 'googl'

module Jwave
  class Updater
    def initialize
      @cache_path = ENV['CACHE_PATH']
    end

    def update
      cache = load_cache
      last_modified, xml = load_xml
      return if cache && !cache.expired?(last_modified)

      data = OnAirData.new(last_modified, xml)
      store_cache data
      tweet build_message(data)
    rescue SocketError => e
      # ignore Name or service not known error
    rescue JSON::ParserError => e
      # ignore twitter error HTML
    end

    private

    # @return [OnAirData, nil]
    def load_cache
      return nil unless File.exist?(@cache_path)
      buf = ''
      File.open(@cache_path, 'r') {|f| buf = f.readlines.join }
      YAML.load buf
    end

    # @return [Array]
    def load_xml
      last_modified = xml = ''
      open(ENV['XML_URL']) do |f|
        last_modified = f.last_modified
        xml = f.readlines.join
      end
      [last_modified, xml]
    end

    # @param [OnAirData] data
    def store_cache(data)
      File.open(@cache_path, 'w') {|f| f.write YAML.dump(data) }
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
      url = shorten_url(data.url)
      "#{data.information} #{url}"
    end

    # @param [String] url
    # @return [String]
    def shorten_url(url)
      url = Googl.shorten(url)
      url.short_url
    end
  end
end
