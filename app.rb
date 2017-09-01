require "sinatra"
require "sinatra/json"
require_relative "app/slack_authorizer"
require_relative "app/command"
require_relative "app/img_flip"

use SlackAuthorizer
MEME_DATABASE = ImgFlip::MemeDatabase.new

post "/" do
  command = Command.new params["text"]
  if command.help?
    res = ["`/meme help` this help"]
    res << "`/meme list` a list of available memes"
    res << "`/meme meme name: caption line 1 [| caption line 2]` generate a meme"    
    json {
      text: res.join("\n")
    }
  elsif command.list?
    MEME_DATABASE.memes.map do |meme|
      [meme.template_url, meme.name]
    end.flatten.join("\n")
  else
    json ImgFlip.new(command).generate!
  end
end

get "/list" do
  MEME_DATABASE.memes.map do |meme|
    [meme.template_url, meme.name]
  end.flatten.join("\n")
end