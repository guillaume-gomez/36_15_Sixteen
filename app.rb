require 'dotenv/load'
require 'sinatra'

require 'httparty'

require_relative 'app/slack_authorizer'

use SlackAuthorizer

class CallSixteen < Sinatra::Base

  post '/slack/command' do
    content = ""
    response_url = params["response_url"]
    username = params["user_name"]
    return if content.empty?
    options  = {
      body: {
        "response_type": "in_channel",
        "text": content,
        "username": username,
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    }
    HTTParty.post(response_url, options)
    ""
  end

  get 'list-user' do
    base_url = "https://slack.com/api/users.list"
    options = {
      headers: { 'Content-Type' => 'application/json' },
      query: {
        token: ENV['SLACK_TOKEN']
      }
    }
    HTTParty.get(base_url, options)
  end

end