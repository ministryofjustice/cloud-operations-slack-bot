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
      User.create(slack_handle: "U029KDGBGNT")
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=6696547d5e4b05f11891c405ba6bd19c17c28a439d79fdb0420c156da7ae7745" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_register.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hi <@U029KDGBGNT>, your slack handle has already been registered.")
      expect(User.count).to eq 1
    end

    it "verifies and responds with the 'selected user' string when slack sends a string 'select' app mention request" do
      User.create(slack_handle: "U029KDGBGNT")
      headers = { "X-Slack-Request-Timestamp" => "1642698248", "X-Slack-Signature" => "v0=b813432e7837882cc3d6474027319c59d72b123f57d48ad4a99a165777aacb89" }
      post "/slack/events", :params => { :slack => JSON.parse(File.read("./spec/lib/data/app_mention_select.json")) }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body).to eql("Hi <@U029KDGBGNT>, you have been selected.")
    end

  end

end
