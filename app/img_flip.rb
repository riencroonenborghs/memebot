require "unirest"

class ImgFlip
  IMGFLIP_URL = "https://api.imgflip.com"

  def self.post!(path, params = {})
    ::Unirest.post(IMGFLIP_URL + path, parameters: params)
  end

  def initialize(command)
    @command  = command
    @meme     = MEME_DATABASE.memes.select{|x| x.name.downcase.match(/#{command.meme_name.downcase}/)}.first
  end

  def generate!
    return "unknown meme #{@command.meme_name}" unless @meme

    params = {
      username:     ENV["IMGFLIP_USERNAME"],
      password:     ENV["IMGFLIP_PASSWORD"],
      template_id:  @meme.id
    }
    params = params.merge!(text0: @command.caption1) if @command.caption1.present?
    params = params.merge!(text1: @command.caption2) if @command.caption2.present?

    response  = self.class.post!("/caption_image", params)
    response.body["data"]["url"]
  end

  class MemeDatabase
    attr_accessor :touched
    attr_accessor :top_100_memes

    def initialize
      load!      
    end

    def load!
      @touched = Time.now
      response = ImgFlip.post!("/get_memes")
      @top_100_memes = response.body["data"]["memes"].map do |hash|
        Meme.new(
          id:           hash["id"],
          name:         hash["name"],
          template_url: hash["url"],
          width:        hash["width"],
          height:       hash["height"],
        )
      end
    end

    def memes
      load! if (@touched + 24*60*60) < Time.now
      @top_100_memes
    end
  end # class MemeDatabase

  class Meme
    attr_accessor :id, :name, :template_url, :width, :height
    def initialize(attrs = {})
      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end
  end # class Meme

end