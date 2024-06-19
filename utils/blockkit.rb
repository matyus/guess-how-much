# frozen_string_literal: true

module Utils
  # Extend this
  module BlockKit
    def header(plain_text)
      raise 'Too many characters' if plain_text.length > 150

      {
        type: :header,
        text: {
          type: :plain_text, # cannot be :mrkdwn
          text: plain_text
        }
      }
    end

    def section(*fields)
      raise 'Too many fields' if fields.length > 10

      {
        type: :section,
        fields:
      }
    end

    def context(*elements)
      raise 'Too many elements' if elements.length > 10

      {
        type: :context,
        elements:
      }
    end

    def text(markdown)
      raise 'Too many characters' if markdown.length > 3000

      {
        type: :mrkdwn,
        text: markdown
      }
    end

    def divider
      { type: :divider }
    end
  end
end
