# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'nokogiri'

module Sources
  # Handling for ssense.com
  class Ssense
    def fetch_page(url)
      ssense_uri = URI(url.strip)

      headers = {
        'User-Agent' => ENV.fetch('USER_AGENT_STRING')
      }

      puts "USER AGENT: #{headers['User-Agent'][0, 8]}"

      Net::HTTP.get(ssense_uri, headers)
    end

    def filter_page(response)
      page = parse_page(response)

      items = page.css('.plp-products__product-tile')

      parsed_items = items.map { |item| parse_item(item) }

      parsed_items.sort { |a, b| a[:product_name] <=> b[:product_name] }
    end

    # create a DOM
    def parse_page(response)
      Nokogiri::HTML.parse(response)
    end

    # parse the node
    def parse_item(item)
      schema = item.css('[type="application/ld+json"]').text
      product = JSON[schema]

      {
        url: product['url'],
        product_name: product['name'],
        # this is the only way to see sale and original prices
        pricing: item.css('.product-tile__pricing').text.gsub(/\n/, '')
      }
    end
  end
end
