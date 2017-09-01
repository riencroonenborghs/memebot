class SlackResponse
  def initialize text
    @text = text
  end

  def render
    {
      response_type: "in_channel",
      text: @text
    }
  end
end