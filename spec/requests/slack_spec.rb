require 'rails_helper'

RSpec.describe "Slack", type: :request do

  describe "POST /events" do
    it "responds with text 'Hello world' when receives post requests" do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/slack/events", :params => { :slack => {"type": "url_verification", "user": "U061F7AUR"}}
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Hello World")
    end
  end

  describe "POST /events" do 
    it "responds with 'Auth Success' when using the credentials" do
      post "/slack/events", :params => { :slack => {"type": "app_mention", "user": "U061F7AUR", "text": "<@U0LAN0Z89> is it everything a river should be?"} }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Authentication successful") 
    end
  end

end
