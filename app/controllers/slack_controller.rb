class SlackController < ApplicationController

  before_action :verify_slack_signature

  def events
    case params[:slack][:type]
    when "url_verification"
      render plain: params.require(:slack).permit(:challenge)[:challenge]
    when "event_callback"
      user = params[:slack][:event][:user]
      channel = params[:slack][:event][:channel]
      case params[:slack][:event][:type]
      when "app_mention"
        ts = params[:slack][:event][:ts]
        message = params[:slack][:event][:text].downcase
        handle_app_mention(user, channel, ts, message)
      when "member_joined_channel"
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

  def handle_app_mention(user, channel, ts, message)
    case message
    when /test/
      render plain: "Hi <@#{user}>, your test was successful.", status: :ok
      HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"thread_ts":ts,"text":":robot_face: :speech_balloon: Hi <@#{user}>, your test was successful. :tada:"})
    when /help/
      render plain: "Hi <@#{user}>, here's some help.", status: :ok
      HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"thread_ts":ts,"text": ":coffee: :robot_face: :smoking: Hi <@#{user}>, you need help? :flushed: Pfft! Alright. \n Mention me, @CloudOpsBot, in your message, in the channel, with the following commands... \n - 'Register' this registers a user to a the channel the command is ran in. \n - 'Select' this selects a registered user in the current channel. \n - 'Deregister' deregisters a user to a the channel the command is ran in. \n - 'Help' - Come on, how did you get here in the first place?!" })
    when /deregister/
      the_user = User.find_by(slack_handle: user, channel_handle: channel)
      if the_user
        the_user.delete
        render plain: "Hi <@#{user}>, you have been successfully deregistered.", status: :ok
        HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"thread_ts":ts,"text":":robot_face: :speech_balloon: Hi <@#{user}>, have been successfully deregistered. :wave:"})
      else
        render plain: "Hi <@#{user}>, you are not registered.", status: :ok
        HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"thread_ts":ts,"text":":robot_face: :heavy_exclamation_mark:  :x: Hi <@#{user}>, You are not even registered! \n :neutral_face:"})
      end
    when /register/
      new_user = User.new(slack_handle: user, channel_handle: channel)
      if new_user.save
        render plain: "Hi <@#{user}>, you have been successfully registered.", status: :ok
        HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"thread_ts":ts,"text":":robot_face: :speech_balloon: Hi <@#{user}>, have been successfully registered. :wave:"})
      else
        render plain: "Hi <@#{user}>, #{new_user.errors.full_messages.first}.", status: :ok
        HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"thread_ts":ts,"text":":robot_face: :heavy_exclamation_mark:  :x: Hi <@#{user}>, #{new_user.errors.full_messages.first}! \n :neutral_face: :point_right: :point_left: :neutral_face:"})
      end
    when /select/
      if User.for_channel(channel).count > 0
        selected_user = User.for_channel(channel).order(Arel.sql('RANDOM()')).first[:slack_handle]
        render plain: "Hi <@#{selected_user}>, you have been selected.", status: :ok
        HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"text":":robot_face: :speech_balloon: Hi <@#{selected_user}>, you have been selected. :wave:"})
      else
        render plain: "Hey, no one is registered.", status: :ok
        HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"text":":robot_face: :heavy_exclamation_mark: No one is registered... so how can I select someone? I've wasted valueable kilobytes of memory on this operation. Maybe run '@CloudOpsBot help' if you don't know what you're doing. :rage: "})
      end
    end

  end

  def handle_member_joined_channel(user, channel)
    render plain: "Hi <@#{user}>, Welcome to the channel.", status: :ok
    HTTP.auth("Bearer #{ENV['SLACK_OAUTH_TOKEN']}").post("https://slack.com/api/chat.postMessage", :json => {"channel":channel,"text":"Hi <@#{user}>, Welcome to the channel."})
  end

end
