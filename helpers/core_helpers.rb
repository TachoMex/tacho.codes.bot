module CoreHelpers
  def bot_started?
    !!metadata[:started]
  end
end