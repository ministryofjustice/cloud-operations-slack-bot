class SlackController < ApplicationController

  before_action :verify_slack_signature

  def events
    if params[:slack][:type] == "url_verification"
      render plain: params.require(:slack).permit(:challenge)[:challenge]
    elsif params[:slack][:event][:type] == "app_mention"
      if params[:slack][:event][:text].include?("test123456789")
        channel = params[:slack][:event][:channel]
        user = params[:slack][:event][:user]
        render plain: "Test successful", status: :ok
        HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"text":"Hi <@#{user}>, Test successful."})
      end
    else
      render plain: ""
    end  
  end

  private

  def verify_slack_signature
    signing_secret = ENV['SLACK_SIGNING_SECRET']
    version_number = 'v0'
    timestamp = request.headers['X-Slack-Request-Timestamp']
    raw_body = request.body.read

    if Time.at(timestamp.to_i) < 5.minutes.ago && Rails.env.production?
      render nothing: true, status: :bad_request
      return
    end

    sig_basestring = [version_number, timestamp, raw_body].join(':')
    digest = OpenSSL::Digest::SHA256.new
    hex_hash = OpenSSL::HMAC.hexdigest(digest, signing_secret, sig_basestring)
    computed_signature = [version_number, hex_hash].join('=')
    slack_signature = request.headers['X-Slack-Signature']

    if computed_signature != slack_signature
      render nothing: true, status: :unauthorized
    end
  end

end
