module Slack
  class Request
    attr_accessor :meme_name, :caption1, :caption2

    HELP          = "help"
    LIST          = "list"
    HELP_MESSAGE  = [].tap do |help|
      help << "`/meme help` this help"
      help << "`/meme list` a list of available memes"
      help << "`/meme meme name: caption line 1 [| caption line 2]` generate a meme"
      help.join("\n")
    end

    def initialize text
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
        list = IMGFLIP_MEME_DATABASE.memes.map do |meme|
          [meme.template_url, meme.name]
        end.flatten.join("\n")

        return Slack::Response::ToYouOnly.text list
      else
        return Slack::Response::ToYouOnly.text HELP_MESSAGE
      end
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