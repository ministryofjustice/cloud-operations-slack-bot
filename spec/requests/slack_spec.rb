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

  end

end
