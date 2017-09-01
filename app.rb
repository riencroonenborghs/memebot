require "sinatra"
require_relative "app/slack_authorizer"

use SlackAuthorizer

post "/" do
  "OK"
end

get "/list" do
  "OK list"
end