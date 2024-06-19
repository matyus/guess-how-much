# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'nokogiri'

# Handlers for ssense.com
class Ssense
  BASE_URL = 'https://www.ssense.com'

  class ProductPageEmptyError < StandardError
  end

  class NoSizesFoundError < StandardError
  end

  class << self
    def designers
      document = get('/en-us/men/sale')

      links = document.css('#designer-list a')

      map = {}

      links.each do |link|
        map[link.text.strip] = link.attributes['href'].value
      end

      map
    end

    def products(path)
      document = get(path)

      items = document.css('.plp-products__product-tile a')

      raise ProductPageEmptyError if items.empty?

      items
    end

    def sizes(path)
      document = get(path)

      # Not all products have a dropdown menu with sizes
      select = document.at_css('#pdpSizeDropdown')

      raise NoSizesFoundError if select.nil?

      options = select.css('option')

      raise NoSizesFoundError if options.empty?

      options
    end

    private

    def get(url)
      uri = URI("#{BASE_URL}#{url.strip}")

      headers = {
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0'
      }

      response = Net::HTTP.get_response(uri, headers)

      if response.is_a? Net::HTTPRedirection
        redirect_uri = URI(response.header['location'])

        response = Net::HTTP.get_response(redirect_uri, headers)
      end

      Nokogiri::HTML.parse(response.body)
    end
  end
end
