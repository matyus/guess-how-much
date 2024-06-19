# frozen_string_literal: true

require 'tty-prompt'

require_relative 'ssense'

# CLI 4 lyfe
class Prompt
  def initialize
    @prompt = TTY::Prompt.new
  end

  def run # rubocop:disable Metric/MethodLength
    product_path = @prompt.select('Designer', Ssense.designers, filter: true)

    items = Ssense.products(product_path)

    item_path = @prompt.select('Product', items, filter: true)

    begin
      sizes = Ssense.sizes(item_path)

      puts sizes
    ensure
      open = @prompt.yes? 'Open URL?'

      `open https://www.ssense.com#{item_path}` if open

      run
    end
  end
end

Prompt.new
