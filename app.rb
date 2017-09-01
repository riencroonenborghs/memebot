require "sinatra"
require_relative "app/slack_authorizer"
require_relative "app/command"
require_relative "app/img_flip"

use SlackAuthorizer

post "/" do
  command = Command.new params["text"]
  if command.list?
    db = ImgFlip::MemeDatabase.new
    res = ["<html><body>"]
    res += db.top_100_memes.map {|x| "<div style='float: left; height: 150px; width: 150px; padding: 2px;'><img src=\"#{x.template_url}\" width='100%' height='75%' /><br/>#{x.name}</div>" } 
    res += ["<div style='clear: both'></div>"]
    res += ["</body></html>"]
    res.join("\n")
  else
  end
end