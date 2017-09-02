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
  slack_request = Slack::Request.new params["text"], request.base_url
  json slack_request.process
end

get "/list" do
  return [].tap do |ret|
    ret << "<html><body>"
    ret << "<style>
      .list .cell { 
        width: 150px; height: 150px; float: left; word-wrap: normal; margin: 4px; 
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        background-size: 160px 160px !important;
      }
      .list .cell h3, .list .cell .bottom { 
        color: white; text-align: center; padding: 0px; margin: 0px; font-size: 9pt;
      }
      .list .cell h3 {
        background: #319225;
        background: -webkit-linear-gradient(#319225, #196b18);
        background: -o-linear-gradient(#319225, #196b18);
        background: -moz-linear-gradient(#319225, #196b18);
        background: linear-gradient(#319225, #196b18);
      }
      .list .cell .bottom {
        background: #196b18;
        background: -webkit-linear-gradient(#196b18, #319225);
        background: -o-linear-gradient(#196b18, #319225);
        background: -moz-linear-gradient(#196b18, #319225);
        background: linear-gradient(#196b18, #319225);    
      }
      .list .cell .bottom pre {
        white-space: pre-wrap;
        white-space: -moz-pre-wrap;
        white-space: -pre-wrap;
        white-space: -o-pre-wrap;
        word-wrap: break-word;
      }
    </style>"
    IMGFLIP_MEME_DATABASE.memes.map do |meme|
      ret << "<div class='list'>
        <div class='cell' style='background: url(#{meme.template_url});'>
          <h3>#{meme.name}</h3>
          <div class='bottom'>
            <small>/meme #{meme.name}: caption line 1 [| caption line 2]</small>
          </div>
        </div>        
      </div>"
    end
    ret << "</body></html>"
  end.join("\n")
end