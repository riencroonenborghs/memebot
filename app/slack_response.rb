class SlackResponse
  def initialize text
    @text = text
  end

  def render(json)
    json response_type: "in_channel", text: @text
  end
end