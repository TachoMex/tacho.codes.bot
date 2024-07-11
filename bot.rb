# frozen_string_literal: true

require_relative 'commands/user_controller'
require_relative 'commands/omegaup_controller'
require_relative 'helpers/omegaup_helpers'
require_relative 'helpers/core_helpers'
require 'omega'

class CompetitiveProgrammingBot < Kybus::Bot::Base
  helpers(OmegaupHelpers)
  helpers(CoreHelpers)

  def initialize(configs)
    super(configs)
    UserController.register_commands(self)
    OmegaupController.register_commands(self)
  end
end
