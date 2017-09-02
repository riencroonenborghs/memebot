module Slack
  class Authorizer
    UNAUTHORIZED_MESSAGE = "Oops! Looks like the application is not authorized! Please review the token configuration."
    UNAUTHORIZED_RESPONSE = ["200", {"Content-Type" => "text"}, [UNAUTHORIZED_MESSAGE]]

    def initialize(app)
      @app = app
    end
    
    def call(env)
      req = Rack::Request.new(env)
      if  req.path_info == "/list" || 
          req.params["token"] == ENV["SLACK_TOKEN"]
        @app.call(env)
      else
        UNAUTHORIZED_RESPONSE
      end
    end
  end
end