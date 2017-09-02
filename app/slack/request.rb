module Slack
  class Request
    attr_accessor :meme_name, :caption1, :caption2

    HELP = "help"
    LIST = "list"

    def initialize text, base_url
      @base_url = base_url
      @meme_name, captions = text.split(/\: /) rescue nil
      @caption1, @caption2 = captions&.split(/\s?\|\s?/)
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
        top_10  = IMGFLIP_MEME_DATABASE.memes.slice(0, 10)

        Slack::Response::ToYouOnly.attachments do
          top_10.map do |meme|
            hash = {
              fallback:   meme.name,
              color:      "#36a64f",
              title:      meme.name,
              text:       "/tv #{meme.name}: caption line 1 [| caption line 2]",
              thumb_url:  meme.template_url
            }
            hash.update(thumb_url: "#{IMAGE_PATH}/#{result["poster_path"]}") if result["poster_path"]
            hash
          end
        end

        # list    = [].tap do |ret|
        #   ret << "*Top 10 memes:*"
        #   top_10.each do |meme|
        #     ret << meme.template_url
        #     ret << meme.name
        #   end
        #   ret << "Full list: #{@base_url}/list"
        # end.join("\n")

        # return Slack::Response::ToYouOnly.text list
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

    def meme?
      !@meme_name.nil? && @meme_name != HELP && @meme_name != LIST
    end
  end
end