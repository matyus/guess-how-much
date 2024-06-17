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

      items = page.css(ENV.fetch('SSENSE_CSS_PATH'))

      parsed_items = items.map { |item| parse_item(item) }

      parsed_items.sort { |a, b| a['name'] <=> b['name'] }
    end

    def parse_page(response)
      Nokogiri::HTML.parse(response)
    end

    # parse the JSON
    def parse_item(item)
      # Example:
      # {
      #   "@context": "https://schema.org",
      #   "@type": "Product",
      #   "productID": "15451661",
      #   "name": "Black & Blue Training Bib 3.0 Shorts",
      #   "brand": {
      #     "@type": "Brand",
      #     "name": "MAAP"
      #   },
      #   "offers": {
      #     "@type": "Offer",
      #     "price": 185,
      #     "priceCurrency": "USD",
      #     "availability": "https://schema.org/InStock",
      #     "url": "/men/product/maap/black-and-blue-training-bib-30-shorts/15451661"
      #   },
      #   "url": "/men/product/maap/black-and-blue-training-bib-30-shorts/15451661",
      #   "image": "https://img.ssensemedia.com/images/241335M193005_1/maap-black-and-blue-training-bib-30-shorts.jpg"
      # }
      JSON[item.content]
    end
  end
end
