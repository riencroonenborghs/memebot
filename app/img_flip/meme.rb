module ImgFlip
  class Meme
    attr_accessor :id, :name, :template_url, :width, :height
    def initialize(attrs = {})
      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end