require "sinatra"
require "sinatra/json"
require_relative "app/slack_authorizer"
require_relative "app/command"
require_relative "app/img_flip"
require_relative "app/slack_response"

use SlackAuthorizer
MEME_DATABASE = ImgFlip::MemeDatabase.new

post "/" do
  command = Command.new params["text"]

  if command.list?
    list = MEME_DATABASE.memes.map do |meme|
      [meme.template_url, meme.name]
    end.flatten.join("\n")
    json SlackResponse::ToYouOnly.text list
  elsif command.meme?
    img_flip = ImgFlip.new(command)
    img_flip.generate!

    if img_flip.ok
      json SlackResponse::InChannel.image_url img_flip.image_url
    else
      json SlackResponse::InChannel.text(img_flip.error_message)
    end
  else
    help = ["`/meme help` this help"]
    help << "`/meme list` a list of available memes"
    help << "`/meme meme name: caption line 1 [| caption line 2]` generate a meme"    
    json SlackResponse::ToYouOnly.text help.join("\n")
  end
end

# get "/list" do
#   list = MEME_DATABASE.memes.map do |meme|
#     [meme.template_url, meme.name]
#   end.flatten.join("\n")
#   json SlackResponse.new(list)
# end