# frozen_string_literal: true

require "minisky"

module Bluesky
  class Client
    include Minisky::Requests
    attr_reader :config

    def initialize(identifier, password, pds_url)
      @pds_url = pds_url
      @config = { "id" => identifier, "pass" => password }
    end

    def host
      URI.parse(@pds_url).host
    end

    def save_config
      # メモリ内管理のため何もしない
    end
  end

  def self.post(text)
    identifier = ENV["BLUESKY_IDENTIFIER"]
    password = ENV["BLUESKY_APP_PASSWORD"]

    raise ArgumentError, "BLUESKY_IDENTIFIER is required" if identifier.nil? || identifier.empty?
    raise ArgumentError, "BLUESKY_APP_PASSWORD is required" if password.nil? || password.empty?

    pds_url = ENV["BLUESKY_PDS_URL"] || "https://bsky.social"
    client = Client.new(identifier, password, pds_url)

    client.post_request("com.atproto.repo.createRecord", {
                          repo: client.user.did,
                          collection: "app.bsky.feed.post",
                          record: {
                            text: text,
                            createdAt: Time.now.iso8601,
                            langs: ["ja"]
                          }
                        })
  end
end
