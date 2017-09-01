require "sinatra"
require "sinatra/json"
require "unirest"

require_relative "app/slack/request"
require_relative "app/slack/response"
require_relative "app/slack/authorizer"
require_relative "app/img_flip/database"
require_relative "app/img_flip/meme"
require_relative "app/img_flip/generator"

use Slack::Authorizer
IMGFLIP_MEME_DATABASE = ImgFlip::Database.new

post "/" do
  request = Slack::Request.new params["text"]
  json request.process
end

get "/list" do
  list = IMGFLIP_MEME_DATABASE.memes.map do |meme|
    [meme.template_url, meme.name]
  end.flatten.join("\n")
  json Slack::Response::ToYouOnly.text list
end