require 'rails_helper'

RSpec.describe "Slack", type: :request do

  describe "POST /events" do

    it "rejects requests when requests cannot be verified to be slack requests" do
      post "/slack/events", :params => { :slack => { "test": "value"} }
      expect(response).to have_http_status(:unauthorized)
    end

    it "verifies and responds with the 'challenge' attribute when slack sends an url-verification post request" do
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=602f3c465b8dd9c5bcec398eb60451ec4de65162b285a802661cb0b5ffe0bc25" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/url_verification.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to include(JSON.parse(File.read("./spec/lib/data/url_verification.json"))["challenge"]) 
    end

    it "verifies and responds with the 'test successful' string when slack sends a string 'test123456789' app mention request" do
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=ba147b9195e5eb14bb9ce1f335f0c4b6b2dca92497a43b49e14fd6a6aa109040" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_test.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Test successful") 
    end

  end

end
