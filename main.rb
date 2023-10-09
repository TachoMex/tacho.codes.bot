require_relative 'lib/services'
require 'kybus/logger'

include Kybus::Logger

#:nocov:
if __FILE__ == $PROGRAM_NAME
  begin
    # Thread.new { Services.bot.observe_contest }
    Services.configure_services!
    Services.bot.run
  rescue StandardError => e
    puts e.message
    raise
  end
end
#:nocov:
