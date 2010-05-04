require 'open-uri'
require 'rexml/document'
require 'twitter_oauth'
require 'bitly'

module Jwave
  class Updater
    def initialize(config)
      @cache_path = config['cache_path']
      @xml_url = config['xml_url']
      @bitly = config['bitly']
      @oauth = config['oauth']
    end

    def update
      cache = load_cache
      last_modified, xml = load_xml
      return if cache && !cache.expired?(last_modified)

      data = OnAirData.new(last_modified, xml)
      store_cache data
      tweet build_message(data)
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
      open(@xml_url) do |f|
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
      t = TwitterOAuth::Client.new(:consumer_key => @oauth['consumer_key'],
                                   :consumer_secret => @oauth['consumer_secret'],
                                   :token => @oauth['token'],
                                   :secret => @oauth['secret'])
      t.update message
    end

    # @param [OnAirData] data
    # @return [String]
    def build_message(data)
      url = shorten_url(data.url)
      "#{data.information} (#{url})"
    end

    # @param [String] url
    # @return [String]
    def shorten_url(url)
      bitly.shorten(url, :histroy => 1).short_url
    end

    # @return [Bitly]
    def bitly
      Bitly.new(@bitly['user_name'], @bitly['api_key'])
    end
  end


  class OnAirData
    attr_reader :last_modified, :information, :url

    # @param [String] last_modified
    # @param [String] xml
    def initialize(last_modified, xml)
      @last_modified = last_modified
      parse(xml)
    end

    # @param [String] last_modified
    # @return [Boolean]
    def expired?(last_modified)
      @last_modified != last_modified
    end

    private

    # @param [String] xml
    def parse(xml)
      doc = REXML::Document.new(xml)
      data = doc.elements['/now_on_air_song/data[1]']
      @information = data.attributes['information']
      @url = data.attributes['cd_url']
    end
  end
end
