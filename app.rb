require "sinatra"
require "sinatra/json"
require_relative "app/slack_authorizer"
require_relative "app/command"
require_relative "app/img_flip"
require_relative "app/slack_response"

use SlackAuthorizer
MEME_DATABASE = ImgFlip::MemeDatabase.new

post "/" do
  return json SlackResponse.new("https://i.imgur.com/j4L9sT4.png").render

  command = Command.new params["text"]
  if command.list?
    MEME_DATABASE.memes.map do |meme|
      [meme.template_url, meme.name]
    end.flatten.join("\n")
  elsif !command.help?
    json image_url: ImgFlip.new(command).generate!
  else
    res = ["`/meme help` this help"]
    res << "`/meme list` a list of available memes"
    res << "`/meme meme name: caption line 1 [| caption line 2]` generate a meme"    
    json text: res.join("\n")
  end
end

get "/list" do
  list = MEME_DATABASE.memes.map do |meme|
    [meme.template_url, meme.name]
  end.flatten.join("\n")
  json SlackResponse.new(list)
end