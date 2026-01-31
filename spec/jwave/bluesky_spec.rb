# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/jwave/bluesky"

RSpec.describe Bluesky do
  describe ".post" do
    context "正常系: 投稿成功" do
      it "Blueskyに投稿できる" do
        allow(ENV).to receive(:[]).with("BLUESKY_IDENTIFIER").and_return("test.bsky.social")
        allow(ENV).to receive(:[]).with("BLUESKY_APP_PASSWORD").and_return("test-password")
        allow(ENV).to receive(:[]).with("BLUESKY_PDS_URL").and_return(nil)

        # minisky gemのモック
        client = instance_double(Bluesky::Client)
        user = instance_double("User", did: "did:plc:test123")

        expect(Bluesky::Client).to receive(:new)
          .with("test.bsky.social", "test-password", "https://bsky.social")
          .and_return(client)

        expect(client).to receive(:user).and_return(user)

        expect(client).to receive(:post_request)
          .with("com.atproto.repo.createRecord", {
                  repo: "did:plc:test123",
                  collection: "app.bsky.feed.post",
                  record: hash_including(
                    text: "Test message",
                    langs: ["ja"],
                  )
                })
          .and_return(true)

        result = Bluesky.post("Test message")
        expect(result).to be_truthy
      end
    end

    context "異常系: 認証情報不足" do
      it "BLUESKY_IDENTIFIERが未設定の場合エラー" do
        allow(ENV).to receive(:[]).with("BLUESKY_IDENTIFIER").and_return(nil)
        allow(ENV).to receive(:[]).with("BLUESKY_APP_PASSWORD").and_return("test-password")

        expect { Bluesky.post("Test") }.to raise_error(ArgumentError, /BLUESKY_IDENTIFIER/)
      end

      it "BLUESKY_APP_PASSWORDが未設定の場合エラー" do
        allow(ENV).to receive(:[]).with("BLUESKY_IDENTIFIER").and_return("test.bsky.social")
        allow(ENV).to receive(:[]).with("BLUESKY_APP_PASSWORD").and_return(nil)

        expect { Bluesky.post("Test") }.to raise_error(ArgumentError, /BLUESKY_APP_PASSWORD/)
      end
    end
  end
end
