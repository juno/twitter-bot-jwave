# frozen_string_literal: true

require "bskyrb"

module Bluesky
  def self.post(text)
    identifier = ENV["BLUESKY_IDENTIFIER"]
    password = ENV["BLUESKY_APP_PASSWORD"]

    raise ArgumentError, "BLUESKY_IDENTIFIER is required" if identifier.nil? || identifier.empty?
    raise ArgumentError, "BLUESKY_APP_PASSWORD is required" if password.nil? || password.empty?

    credentials = Bskyrb::Credentials.new(identifier, password)
    pds_url = ENV["BLUESKY_PDS_URL"] || "https://bsky.social"
    session = Bskyrb::Session.new(credentials, pds_url)
    record_manager = Bskyrb::RecordManager.new(session)
    record_manager.create_post(text)
  end
end
