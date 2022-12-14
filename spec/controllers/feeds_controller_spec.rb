# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe FeedsController do
  describe "#fetch" do
    let(:canteen) { create(:canteen, :with_meals) }
    let(:parser) { create(:parser, user: owner) }
    let(:source) { create(:source, canteen: canteen, parser: parser) }
    let(:feed) { create(:feed, source: source) }
    let(:owner) { create(:developer) }
    let(:updater) { OpenMensa::Updater.new(feed, "manual") }
    let(:json) { JSON.parse response.body }

    before do
      updater
      allow(OpenMensa::Updater).to receive(:new).with(feed, "manual").and_return updater
    end

    it "runs openmensa updater" do
      expect(updater).to receive(:update).and_return true
      get :fetch, format: :json, params: {id: feed.id}

      expect(response).to have_http_status :ok
    end

    context "should return update information" do
      let(:successfull_json) do
        {
          "status" => "ok",
          "days" => {
            "added" => 1,
            "updated" => 0
          },
          "meals" => {
            "added" => 3,
            "updated" => 4,
            "removed" => 5
          }
        }
      end

      before do
        expect(updater).to receive(:update).and_return true
        expect(updater.fetch).to receive(:added_days).at_least(:once).and_return 1
        expect(updater.fetch).to receive(:updated_days).at_least(:once).and_return 0
        expect(updater.fetch).to receive(:added_meals).at_least(:once).and_return 3
        expect(updater.fetch).to receive(:updated_meals).at_least(:once).and_return 4
        expect(updater.fetch).to receive(:removed_meals).at_least(:once).and_return 5
      end

      it "and render them for canteen owner" do
        set_current_user owner
        get :fetch, format: :json, params: {id: feed.id}

        expect(response).to have_http_status :ok
        expect(response.media_type).to eq "application/json"

        expect(json).to eq successfull_json

        expect(assigns(:result)).to eq json
      end

      it "and not render them for normal user" do
        get :fetch, format: :json, params: {id: feed.id}

        expect(response).to have_http_status :ok
        expect(response.media_type).to eq "application/json"

        expect(json).to eq successfull_json

        expect(assigns(:result)).to eq("status" => "ok")
      end
    end

    context "should return occured errors" do
      let(:feed_fetch_error) do
        FeedFetchError.create(messageable: updater.fetch,
          message: "Could not fetch",
          code: 404)
      end
      let(:json_error) do
        {
          "status" => "error",
          "errors" => [
            {
              "type" => "feed_fetch_error",
              "message" => "Could not fetch",
              "code" => 404
            }
          ]
        }
      end

      before do
        expect(updater).to receive(:update).and_return false
        expect(updater).to receive(:errors).at_least(:once) do
          [feed_fetch_error]
        end
      end

      it "and render them for canteen owner" do
        set_current_user owner
        get :fetch, format: :json, params: {id: feed.id}

        expect(response).to have_http_status :ok
        expect(response.media_type).to eq "application/json"

        expect(json).to eq json_error

        expect(assigns(:result)).to eq({
          "status" => "error",
          "errors" => [feed_fetch_error]
        })
      end

      it "and not render them for normal users" do
        get :fetch, format: :json, params: {id: feed.id}

        expect(response).to have_http_status :ok
        expect(response.media_type).to eq "application/json"

        expect(json).to eq json_error

        expect(assigns(:result)).to eq("status" => "error")
      end
    end

    it "only allows one fetch per 15 minute" do
      expect(updater).not_to receive(:update)
      create(:feed_fetch, feed: feed, state: "failed", executed_at: 14.minutes.ago)
      get :fetch, format: :json, params: {id: feed.id}
      expect(response).to have_http_status :too_many_requests
    end

    it "updates from canteen owner every time" do
      set_current_user owner
      expect(updater).to receive(:update).and_return true
      create(:feed_fetch, feed: feed, state: "failed", executed_at: Time.zone.now)
      get :fetch, format: :json, params: {id: feed.id}
      expect(response).to have_http_status :ok
    end
  end
end
