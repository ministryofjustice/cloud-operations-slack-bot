require 'rails_helper'

RSpec.describe "Slack", type: :request do

  describe "GET /" do
    it "responds with welcome" do
      get "/"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /events" do

    it "rejects requests when requests cannot be verified to be slack requests" do
      post "/slack/events", :params => { :slack => { "test": "value"} }
      expect(response).to have_http_status(:unauthorized)
    end

    it "verifies and responds with the 'challenge' attribute when slack sends an url-verification post request" do
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=602f3c465b8dd9c5bcec398eb60451ec4de65162b285a802661cb0b5ffe0bc25" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/url_verification.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql(JSON.parse(File.read("./spec/lib/data/url_verification.json"))["challenge"]) 
    end

    it "verifies and responds with the 'test successful' string when slack sends a string 'test123456789' app mention request" do
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=ba147b9195e5eb14bb9ce1f335f0c4b6b2dca92497a43b49e14fd6a6aa109040" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_test.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hi <@U029KDGBGNT>, your test was successful.") 
    end

    it "verifies and responds with the 'confirmation' string when slack sends a string 'register' app mention request" do
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=6696547d5e4b05f11891c405ba6bd19c17c28a439d79fdb0420c156da7ae7745" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_register.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hi <@U029KDGBGNT>, you have been successfully registered.")
      expect(User.count).to eq 1
    end

    it "verifies and responds with the 'error message' string when slack sends a string 'register' app mention request and user is already registered" do
      User.create(slack_handle: "U029KDGBGNT", channel_handle: "C02TNSV394Y")
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=6696547d5e4b05f11891c405ba6bd19c17c28a439d79fdb0420c156da7ae7745" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_register.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hi <@U029KDGBGNT>, your slack handle has already been registered.")
      expect(User.count).to eq 1
    end

    it "verifies and responds with the 'selected user' from the same channel when slack sends a string 'select' app mention request from a channel" do
      User.create(slack_handle: "URANDOM1", channel_handle: "C02TNSV394Y")
      User.create(slack_handle: "U2", channel_handle: "C2")
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=b813432e7837882cc3d6474027319c59d72b123f57d48ad4a99a165777aacb89" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_select.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hi <@URANDOM1>, you have been selected.")
    end

    it "verifies and responds with the 'no one registered' message when slack sends a string 'select' app mention request from a channel and no one is registered" do
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=b813432e7837882cc3d6474027319c59d72b123f57d48ad4a99a165777aacb89" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_select.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hey, no one is registered.")
    end

    it "verifies and responds with the 'no one registered' message when slack sends a string 'select' app mention request from a channel and no one is registered from that particular channel" do
      User.create(slack_handle: "U2", channel_handle: "C2")
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=b813432e7837882cc3d6474027319c59d72b123f57d48ad4a99a165777aacb89" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_select.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hey, no one is registered.")
    end

    it "verifies and responds with all registered users in the channel when slack sends a string 'list' app mention request from a given channel" do
      User.create(slack_handle: "U1", channel_handle: "C02TNSV394Y")
      User.create(slack_handle: "U2", channel_handle: "C02TNSV394Y")
      User.create(slack_handle: "U3", channel_handle: "C02TNSV394Y")
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=84f096fcdfb273027d2db5972f98ca0b9759bc06889bea6848f34f14b95439df" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_list.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to include("U1", "U2", "U3")
    end

    it "verifies and responds with 'help' message when slack sends a string 'help' app mention request from a channel" do 
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=fe7c0d0cc0fb94eb1ae7bfbdc783d2f69e5b0d41de970d5d46fed65633847eeb" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_help.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hi <@U029KDGBGNT>, here's some help.")
    end
    
    it "verifies and responds with the 'successful deregistration' message when slack sends a string 'deregister' app mention request from a channel and user is registered" do
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=882941076c1d5a6846f182c1c7cf76c7a60d79331897c928a8668a30f94c9be3" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_deregister.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hi <@U029KDGBGNT>, you are not registered.")
      expect(User.count).to eq 0
    end

    it "verifies and responds with the 'new incident created' message when slack sends a string 'incident' app mention request from a channel and user is registered" do
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=2aec3edd38a73c8e968cc87c1db6ce5773273a8cea68c75cb9c7ca569820f3c7" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_incident.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to include("INC")
      expect(User.count).to eq 0
    end
  end

end
