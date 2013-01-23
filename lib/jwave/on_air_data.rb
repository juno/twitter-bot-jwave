require 'rexml/document'

module Jwave
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
