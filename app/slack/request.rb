module Slack
  class Request
    attr_accessor :meme_name, :caption1, :caption2
    attr_accessor :response_url

    HELP = "help"
    LIST = "list"
    MEMES_PER_PAGE = 5

    def initialize params, base_url
      @base_url = base_url
      # payload
      @payload = JSON.parse params[:payload] || "{}"
      # meme, captions
      @meme_name, captions = params[:text].split(/\: /) rescue nil
      @caption1, @caption2 = captions&.split(/\s?\|\s?/)
      # response_url for >3s responses
      @response_url = params[:response_url] || @payload["response_url"]
    end

    def process
      if meme?
        img_flip = ImgFlip::Generator.new self
        if img_flip.generate
          return Slack::Response::InChannel.image_url img_flip.image_url
        else
          return Slack::Response::ToYouOnly.text img_flip.error_message
        end
      elsif list?
        return process_list
      end

      help = ["`/meme help` this help"]
      help << "`/meme list` a list of available memes"
      help << "`/meme meme name: caption line 1 [| caption line 2]` generate a meme"
      help = help.join("\n")

      return Slack::Response::ToYouOnly.text help
    end

  private

    def help?
      @meme_name == HELP || @meme_name.nil?
    end

    def list?
      @meme_name == LIST
    end
    def process_list(page = 1)
      from  = (page - 1) * MEMES_PER_PAGE
      to    = from += MEMES_PER_PAGE
      list  = IMGFLIP_MEME_DATABASE.memes.slice from, to
      return Slack::Response::ToYouOnly.attachments do
        attachments = list.map do |meme|
          {
            fallback:   meme.name,
            color:      "#36a64f",
            title:      meme.name,
            text:       "/meme #{meme.name}: caption line 1 [| caption line 2]",
            thumb_url:  meme.template_url
          }
        end
        buttons = {actions: []}
        buttons[:actions] << {name: "previous_page", text: "Previous Page", type: "button", value: "previous_page"} if from > 0
        buttons[:actions] << {name: "next_page", text: "Next Page", type: "button", value: "next_page"} if to < IMGFLIP_MEME_DATABASE.memes.size
        attachments << buttons
        attachments
      end
    end

    def meme?
      !@meme_name.nil? && @meme_name != HELP && @meme_name != LIST
    end
  end
end