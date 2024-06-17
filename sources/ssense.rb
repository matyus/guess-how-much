# frozen_string_literal: true

require_relative '../utils/slack'
require_relative 'ssense/main'

client = Sources::Ssense.new
slack = Utils::Slack.new

urls = ARGF.readlines

urls.each do |url| # rubocop:disable Metrics/BlockLength
  # if a row is commented out with a `#`, then skip it
  next if url.strip.start_with?('#')

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
          text: url.strip.split('/').last
        }
      },
      # row 2
      {
        type: :context,
        elements: [
          {
            type: :mrkdwn,
            text: url.strip
          }
        ]
      }
    ]
  }

  # create a section (row) for each item
  items.map! do |item|
    {
      type: :section,
      text: {
        type: :mrkdwn,
        text: "<https://ssense.com/en-us#{item['url']}|#{item['name']}> $#{item['offers']['price']}"
      }
    }
  end

  # append them to the blocks[]
  items.each { |item| data[:blocks] << item }

  response = slack.send(data)

  puts "URL:      #{url}"
  puts "DATA:     #{data}"
  puts "RESPONSE: #{response}"
  puts ' '
end
