class Command
  def initialize(text)
    @meme, captions = text.split(/\:/)
    _, @caption1, _, @caption2 = captions&.split(/\"/)
  end

  def list?
    @meme == "list"
  end
end