# memebot

*memebot* is a Slack bot for generating memes.
It's written in Ruby/Sinatra.

# Get it up and running

- create a [Slack App](https://api.slack.com/apps) (Slash Commands)
- sign up at [ImgFlip](https://imgflip.com/signup)
- deploy *memebot* somewhere and make sure Slack App's API token (_SLACK_TOKEN_) and ImgFlip's username/password (_IMGFLIP_USERNAME/IMGFLIP_PASSWORD_) are available in the environment (.env or something)

# How to

`/meme help` 


`/meme list` 
Returns a list of the top 10 meme and a link to a longer list.

`/meme Meme Name Goes Here: caption line 1 [| caption line 2]`
Generates the meme with your captions.
