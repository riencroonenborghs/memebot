require "sinatra"
require_relative "app/slack_authorizer"
require_relative "app/command"
require_relative "app/img_flip"

use SlackAuthorizer

post "/" do
  command = Command.new params["text"]
  if command.help?
    "`/meme help` for this help, `/meme list` for a list of available memes or `/meme meme name: \"caption\" [\"caption\"]` for meme"
  elsif command.list?
    db = ImgFlip::MemeDatabase.new
    db.top_100_memes.map do |meme|
      [meme.template_url, meme.name]
    end.flatten.join("\n")
  end
end