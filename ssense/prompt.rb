# frozen_string_literal: true

require 'tty-prompt'

require_relative 'ssense'

# CLI 4 lyfe
class Prompt
  attr_reader :designers, :products

  def initialize
    @prompt = TTY::Prompt.new
    @designers = Ssense.designers.map { |designer| format_selection(designer) }

    run
  end

  def run # rubocop:disable Metrics/MethodLength
    product_path = @prompt.select('Designer', @designers, filter: true)

    items = Ssense.products(product_path).map { |item| format_selection(item) }

    item_path = @prompt.select('Product', items, filter: true)

    # not all things have "sizes"
    begin
      sizes = Ssense.sizes(item_path).map { |size| size.content.delete("\n") }

      puts sizes
    ensure
      open = @prompt.yes? 'Open URL?'

      `open #{Ssense::BASE_URL}#{item_path}` if open

      run if ENV.fetch('AUTOLOAD', 'true') == 'true'
    end
  end

  private

  # https://github.com/piotrmurach/tty-prompt?tab=readme-ov-file#261-choices
  # define an array of choices where each choice is a hash value with :name & :value keys
  def format_selection(element)
    {
      value: element.attributes['href'].value,
      name: element.text.delete("\n").strip
    }
  end
end

Prompt.new if ENV.fetch('AUTOLOAD', 'true') == 'true'
