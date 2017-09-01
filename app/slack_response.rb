class SlackResponse
  IN_CHANNEL = {response_type: "in_channel"}
  def self.text(text)
    IN_CHANNEL.update(text: text)
  end
  def self.image_url(image_url)
    IN_CHANNEL.update(attachments: [image_url: image_url])
  end
end