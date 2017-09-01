class Command
  attr_accessor :meme_name, :caption1, :caption2

  HELP = "help"
  LIST = "list"

  def initialize(text)
    @meme_name, captions = text.split(/\: /)
    @caption1, @caption2 = captions&.split(/\s?\|\s?/)
  end

  def help?
    @meme_name == HELP
  end

  def list?
    @meme_name == LIST
  end

  def meme?
    @meme_name != HELP && @meme_name != LIST
end