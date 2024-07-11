# frozen_string_literal: true

module CoreHelpers
  def bot_started?
    !!metadata[:started]
  end
end
