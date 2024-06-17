# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Utils
  # Send Slack messages to the given webhook
  class Slack
    HEADERS = {
      'Content-Type' => 'application/json'
    }.freeze

    def initialize(url: ENV.fetch('SLACK_WEBHOOK_URL'))
      @slack_uri = URI(url)
    end

    def send(data = { text: 'Default' })
      body = JSON.dump(data)

      puts "PORT: #{@slack_uri.port}"
      puts "BODY: #{body}"

      response = Net::HTTP.post(@slack_uri, body, HEADERS)

      response.body
    end
  end
end
