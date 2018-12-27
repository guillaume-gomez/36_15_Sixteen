require 'dotenv/load'
require 'sinatra/base'
require 'slack-ruby-client'

require 'byebug'

def create_slack_client(slack_api_secret = ENV['SLACK_API_TOKEN'])
  Slack.configure do |config|
    config.token = slack_api_secret
    raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
  end
  Slack::Web::Client.new
end

def format_message(content, user = nil, as_user = false)
  headers = [
    "Someone needs you ! :prière: .",
    "Vite ! C'est urgent !",
    "On sait qu'on est pénible mais ...",
    "J'ai deja demandé aux autres, mais ils savent pas :(",
  ]
  header = headers.sample
  body = ">>> #{content}"
  footer = user && as_user ? "message de : *#{user["profile"]["display_name"]}*" : ""
  header + "\n" + body + "\n" + footer
end


class CallSixteen < Sinatra::Base

  attr_accessor :target_user

  def initialize(app = nil)
    super(app)
    @client = create_slack_client();
    @client.auth_test
    @sixteen_user_id = ENV["USER_ID"]
    @target_user = nil
    # fetch users
    result = @client.users_list
    members = result["members"] || []
    @users = members.map{|member| member.slice("id", "profile") }
  end

  post '/slack/command' do
    channel = @target_user&.id || @sixteen_user_id
    text, as_user = params["text"].split("|")
    text = text.strip
    user_info = @users.select{|user| user["id"] == params["user_id"]}.first
    as_user =  (as_user && as_user.strip == "true" && user_info) ? params["user_id"] : false
    @client.chat_postMessage(channel: channel, text: format_message(text, user_info, as_user))
    ""
  end

  get '/list-user' do
    user = params["user"] || ""
    result = @client.users_list
    return "" if result.nil?
    if result["members"]
      members = result["members"]
      @target_user = members.select{|member| member["profile"]["display_name"] == user}
      @target_user.to_json
    else
      "user cannot be found"
    end

  end

end