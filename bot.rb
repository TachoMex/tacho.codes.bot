# frozen_string_literal: true

require_relative 'commands/user_controller'
require_relative 'helpers/omegaup_helpers'
require_relative 'helpers/core_helpers'

class CompetitiveProgrammingBot < Kybus::Bot::Base
  MISSING_OMEGAUP_USER = 'Debes registrar tu usuario de omegaup primero con /registro_omegaup'
  HELP_MESSAGE = "Este bot te ayuda a administrar tus concursos de omegaup. De momento está limitado su acceso. Más información en github.com/tachomex/competitive_programming_bot"

  helpers(OmegaupHelpers)
  helpers(CoreHelpers)

  def initialize(configs)
    super(configs)
    UserCommands.register_commands(self)
  end
end
