module Slack
  class Request
    attr_accessor :meme_name, :caption1, :caption2
    attr_accessor :response_url

    HELP = "help"
    LIST = "list"
    MEMES_PER_PAGE = 5

    def initialize params, base_url
      @base_url = base_url
      # payload and actions
      @payload  = JSON.parse params[:payload] || "{}"
      @actions  = @payload["actions"] || []
      # meme, captions
      @meme_name, captions = params[:text].split(/\: /) rescue nil
      @caption1, @caption2 = captions&.split(/\s?\|\s?/)
      # response_url for >3s responses
      @response_url = params[:response_url] || @payload["response_url"]
    end

    def process
      if actions?
        return process_actions
      elsif meme?
        return process_memes        
      elsif list?
        return process_list
      end

      process_help      
    end

  private

    def actions?
      @actions.any?
    end
    def process_actions
      begin
        attachments = [].tap do |ret|
          @actions.each do |action|
            ret << process_list_attachments(action["value"].to_i) if action["name"] == "previous_page"
            ret << process_list_attachments(action["value"].to_i) if action["name"] == "next_page"
          end
        end.flatten
        
        Slack::Response::ToYouOnly.new_attachments do
          attachments
        end
      rescue => e
        Slack::Response::ToYouOnly.error e
      end
    end

    def process_help
      help = ["`/meme help` this help"]
      help << "`/meme list` a list of available memes"
      help << "`/meme meme name: caption line 1 [| caption line 2]` generate a meme"
      help = help.join("\n")
      return Slack::Response::ToYouOnly.text help
    end

    def list?
      @meme_name == LIST
    end
    def process_list(page = 1)
      return Slack::Response::ToYouOnly.attachments do 
        process_list_attachments(page)
      end
    end
    def process_list_attachments(page = 1)
      from  = (page - 1) * MEMES_PER_PAGE
      to    = from + MEMES_PER_PAGE
      total = IMGFLIP_MEME_DATABASE.memes.size
      list  = IMGFLIP_MEME_DATABASE.memes.slice from, to
      attachments = list.map do |meme|
        {
          fallback:   meme.name,
          color:      "#36a64f",
          title:      meme.name,
          text:       "/meme #{meme.name}: caption line 1 [| caption line 2]",
          thumb_url:  meme.template_url
        }
      end
      buttons = {
        fallback:     "Showing #{from+1} to #{to} of #{total}",
        text:         "Showing #{from+1} to #{to} of #{total}", 
        callback_id:  Time.now.usec,
        actions: []
      }
      buttons[:actions] << {name: "previous_page", text: "Previous Page", type: "button", value: page - 1} if from > 0
      buttons[:actions] << {name: "next_page", text: "Next Page", type: "button", value: page + 1} if to < IMGFLIP_MEME_DATABASE.memes.size
      attachments << buttons
      attachments
    end

    def meme?
      !@meme_name.nil? && @meme_name != HELP && @meme_name != LIST
    end
    def process_memes
      img_flip = ImgFlip::Generator.new self
      if img_flip.generate
        return Slack::Response::InChannel.image_url img_flip.image_url
      else
        return Slack::Response::ToYouOnly.text img_flip.error_message
      end
    end

  end
end