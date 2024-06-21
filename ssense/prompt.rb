# frozen_string_literal: true

require 'tty-prompt'
require 'tty-logger'

require_relative 'ssense'

# CLI 4 lyfe
class Prompt
  attr_reader :designers, :products

  def initialize(run)
    @run = run == 'true'
    @prompt = TTY::Prompt.new
    @logger = TTY::Logger.new
    @designers = Ssense.designers.map { |designer| format_selection(designer) }

    main if @run
  end

  def main # rubocop:disable Metrics/MethodLength
    product_path = @prompt.select('Designer', @designers, filter: true)

    items = Ssense.products(product_path).map { |item| format_selection(item) }

    item_path = @prompt.select('Product', items, filter: true)

    # not all things have "sizes"
    begin
      Ssense.sizes(item_path).each do |size|
        next if size.text =~ /SELECT A SIZE/

        @logger.info(size.text.strip)
      end
    ensure
      open = @prompt.yes? 'Open URL?'

      `open #{Ssense::BASE_URL}#{item_path}` if open

      main if @run
    end
  end

  private

  # https://github.com/piotrmurach/tty-prompt?tab=readme-ov-file#261-choices
  # define an array of choices where each choice is a hash value with :name & :value keys
  # note: selections navigate, so they are always <a> elements (see: ssense.rb)
  def format_selection(element)
    {
      value: element.attributes['href'].value,
      name: element.text.delete("\n").strip
    }
  end
end

# if you don't want to auto-run the prompt, set RUN=false
run = ENV.fetch('RUN', 'true')

Prompt.new(run)
