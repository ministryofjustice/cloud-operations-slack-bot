class SlackController < ApplicationController

  before_action :verify_slack_signature

  def events
    case params[:slack][:type]
    when "url_verification"
      render plain: params.require(:slack).permit(:challenge)[:challenge]
    when "event_callback"
      case params[:slack][:event][:type]
      when "app_mention"
        user = params[:slack][:event][:user]
        channel = params[:slack][:event][:channel]
        message = params[:slack][:event][:text].downcase
        handle_app_mention(user, channel, message)
      when "member_joined_channel"
        user = params[:slack][:event][:user]
        channel = params[:slack][:event][:channel]
        handle_member_joined_channel(user, channel)
      end
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

  def handle_app_mention(user, channel, message)
    case message
    when /test/
      render plain: "Hi <@#{user}>, your test was successful.", status: :ok
      HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"text":"Hi <@#{user}>, your test was successful. :tada:"})
    end
  end

  def handle_member_joined_channel(user, channel)
    render plain: "Hi <@#{user}>, Welcome to the channel.", status: :ok
    HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"text":"Hi <@#{user}>, Welcome to the channel."})
  end

end
