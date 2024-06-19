# frozen_string_literal: true

require 'tty-prompt'

require_relative 'ssense'

# CLI 4 lyfe
class Prompt
  def initialize
    @prompt = TTY::Prompt.new

    run
  end

  def run # rubocop:disable Metric/MethodLength
    product_path = @prompt.select('Designer', Ssense.designers, filter: true)

    items = Ssense.products(product_path).map { |item| format_choice(item) }

    item_path = @prompt.select('Product', items, filter: true)

    begin
      sizes = Ssense.sizes(item_path).map { |element| element.content.delete("\n") }

      puts sizes
    ensure
      open = @prompt.yes? 'Open URL?'

      `open #{Ssense::BASE_URL}#{item_path}` if open

      run
    end
  end

  private

  # https://github.com/piotrmurach/tty-prompt?tab=readme-ov-file#261-choices
  # define an array of choices where each choice is a hash value with :name & :value keys
  def format_choice(element)
    {
      value: element.attributes['href'].value,
      name: element.text.delete("\n").strip
    }
  end
end

Prompt.new
