module Slack
  class Response
    class InChannel
      IN_CHANNEL = {response_type: "in_channel"}
      def self.text text
        IN_CHANNEL.update(text: text)
      end
      def self.image_url image_url
        IN_CHANNEL.update(attachments: [{replace_original: false, image_url: image_url}])
      end
    end
    
    class ToYouOnly
      def self.text text
        {text: text}
      end
      def self.attachments& block
        ret = {
          attachments: yield 
        }
      end
      def self.replace_attachments& block
        ret = {
          replace_original: true,
          attachments: yield
        }
      end        
      def self.error message
        {attachments: [
          {text: message, color: "#ff0000", pretext: "An error occurred"}
        ]}
      end
    end

    def self.post url, data
      ::Unirest.post url, headers: {"Accept" => "application/json"}, parameters: data
    end
  end
end