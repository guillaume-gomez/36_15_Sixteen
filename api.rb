require 'dotenv/load'
require 'sinatra/base'
require 'slack-ruby-client'

require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new

client.auth_test

user_sixteen = ""

class CallSixteen < Sinatra::Base

  post '/slack/command' do
    client.chat_postMessage(channel: '#general', text: 'Hello World', as_user: true)
  end

  get 'list-user' do
    user = params["user"]
    client.users_search(user: user)
  end

end