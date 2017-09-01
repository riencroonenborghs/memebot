module ImgFlip
  class Database
    attr_accessor :touched
    attr_accessor :top_100_memes

    def initialize
      load!      
    end

    def load!
      @touched = Time.now
      response = ImgFlip::Generator.post!("/get_memes")
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
  end
end