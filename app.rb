require "sinatra"
require_relative "app/slack_authorizer"
require_relative "app/command"
require_relative "app/img_flip"

use SlackAuthorizer
MEME_DATABASE = ImgFlip::MemeDatabase.new

post "/" do
  command = Command.new params["text"]
  if command.help?
    res = ["`/meme help` for this help"]
    res << "`/meme list` for a list of available memes"
    res << "`/meme meme name: \"caption\" [\"caption\"]` for meme"
    res.join("\n")
  elsif command.list?
    MEME_DATABASE.memes.map do |meme|
      [meme.template_url, meme.name]
    end.flatten.join("\n")
  else
    ImgFlip.new(command).generate!
  end
end