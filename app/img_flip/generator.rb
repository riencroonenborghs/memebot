module ImgFlip
  class Generator
    attr_accessor :image_url, :error_message

    IMGFLIP_URL = "https://api.imgflip.com"

    def self.post!(path, params = {})
      ::Unirest.post(IMGFLIP_URL + path, parameters: params)
    end

    def initialize(slack_request)
      @slack_request  = slack_request
      @meme           = IMGFLIP_MEME_DATABASE.memes.select{|x| x.name.downcase.match(/#{slack_request.meme_name.downcase}/)}.first
    end

    def generate
      unless @meme
        @error_message = "Unknown meme `#{@slack_request.meme_name}`"
        return false
      end

      params = {
        username:     ENV["IMGFLIP_USERNAME"],
        password:     ENV["IMGFLIP_PASSWORD"],
        template_id:  @meme.id
      }
      params.update(text0: @slack_request.caption1) if @slack_request.caption1
      params.update(text1: @slack_request.caption2) if @slack_request.caption2

      response = self.class.post!("/caption_image", params)
      if response.body["success"]
        @image_url = response.body["data"]["url"]
        return true
      else
        @error_message = response.body["error_message"]
        return false
      end
    end  
  end
end