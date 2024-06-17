# frozen_string_literal: true

require_relative '../utils/slack'
require_relative 'ssense/main'

client = Sources::Ssense.new
slack = Utils::Slack.new

lines = ARGF.readlines

lines.each do |line| # rubocop:disable Metrics/BlockLength
  puts "READLINE: #{line}"

  url = line.strip

  # if a row is commented out with a `#`, then skip it
  next if url.start_with?('#')

  web_page = client.fetch_page(url)

  items = client.filter_page(web_page)

  # `data` formatting must conform:
  # https://app.slack.com/block-kit-builder/
  data = {
    blocks: [
      # row 1
      {
        type: :header,
        text: {
          type: :plain_text,
          text: url.split('/').last
        }
      },
      # row 2
      {
        type: :context,
        elements: [
          {
            type: :mrkdwn,
            text: url
          }
        ]
      }
    ]
  }

  # create a section (row) for each item
  items.each do |item|
    data[:blocks] << {
      type: :section,
      text: {
        type: :mrkdwn,
        text: "<https://ssense.com/en-us#{item[:url]}|#{item[:product_name]}> #{item[:pricing]}"
      }
    }
  end

  response = slack.send(data)

  puts "URL:      #{url}"
  puts "DATA:     #{data}"
  puts "RESPONSE: #{response}"
  puts ' '
end
