# frozen_string_literal: true

require "nokogiri"

module Jwave
  # Represent on-air data
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

    def to_s
      "#{information} #{url}"
    end

    private

    # @param [String] xml
    def parse(xml)
      doc = Nokogiri::XML(xml)
      node = doc.xpath("//now_on_air_song/data").first
      @information = node.attr("information")
      @url = node.attr("amazon_url")
    end
  end
end
