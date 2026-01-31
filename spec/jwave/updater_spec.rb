# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/jwave/on_air_data"
require_relative "../../lib/jwave/updater"

RSpec.describe Jwave::Updater do
  describe "#update" do
    let(:xml_content) do
      File.read(File.expand_path("../fixtures/now_on_air_song_v2.xml", __dir__))
    end
    let(:last_modified) { Time.now }
    let(:updater) do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("REDIS_URL").and_return("redis://localhost:6379")
      described_class.new
    end

    before do
      # Redis mock
      allow_any_instance_of(described_class).to receive(:load_cache).and_return(nil)
      allow_any_instance_of(described_class).to receive(:store_cache)

      # XML loading mock
      allow_any_instance_of(described_class).to receive(:load_xml).and_return([last_modified, xml_content])
    end

    context "Bluesky統合" do
      it "Bluesky.postが呼ばれる" do
        expect(Bluesky).to receive(:post).with(kind_of(String))
        updater.update
      end

      it "投稿メッセージに曲情報とURLが含まれる" do
        posted_message = nil
        allow(Bluesky).to receive(:post) { |msg| posted_message = msg }

        updater.update

        expect(posted_message).to include("BRAVE GENERATION")
        expect(posted_message).to match(/https?:\/\//)
      end
    end
  end
end
