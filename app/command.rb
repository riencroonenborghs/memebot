class Command
  attr_accessor :meme_name, :caption1, :caption2

  def initialize(text)
    @meme_name, captions = text.split(/\:/)
    _, @caption1, _, @caption2 = captions&.split(/\"/)
  end

  def help?
    @meme_name == "help"
  end

  def list?
    @meme_name == "list"
  end
end