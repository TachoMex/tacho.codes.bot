# frozen_string_literal: true

require_relative '../test_helper'

class TestOmegaupController < BotTest
  DEFAULT_CONTEST_DATA = {
    alias: 'concurso_test'
  }.freeze

  SAMPLE_CLARIF = {
    answer: nil,
    problem_alias: 'some-problem',
    message: 'tengo un problema',
    clarification_id: 123
  }.freeze

  def test_administer_contest_without_admin_group
    @bot.receives('/iniciar')
    @bot.receives('/administrar_concurso')
    @bot.expects(:send_message).with('Necesitas dar de alta el grupo de admins primero /registrar_grupo_admins')
    @bot.receives('concurso_test')
  end

  def test_administer_contest_with_admin_group
    @bot.receives('/iniciar')
    @bot.metadata[:admin_group] = 'grupo_admins'
    @bot.save_metadata!
    stub_omega(:post, '/api/contest/details/', 'contest_alias=concurso_test')
    @bot.receives('/administrar_concurso')
    Omega::Contest.any_instance.expects(:group_admin?).with('grupo_admins').returns(true)
    @bot.expects(:send_message).with('Se va a administrar el concurso concurso_test')
    @bot.receives('concurso_test')
  end

  def test_add_user_to_contest
    @bot.receives('/iniciar')
    set_contest
    @bot.receives('/agregar_usuario')
    @bot.expects(:send_message).with('Se registró el usuario usuario_test en concurso_test')
    OMEGAUPCLI.expects(:add_user_to_contest)
    @bot.receives('usuario_test')
  end

  def test_add_problem_to_contest
    @bot.receives('/iniciar')
    set_contest
    @bot.receives('/añadir_problema')
    OMEGAUPCLI.expects(:add_problem_to_contest)
    @bot.expects(:send_message).with('Se registró el problema problema_test en concurso_test')
    @bot.receives('problema_test')
  end

  def test_activate_notifications
    @bot.receives('/iniciar')
    set_contest
    @bot.expects(:send_message).with('Se han activado las notificaciones')
    @bot.expects(:fork).with('contest_observer_clarif', contest: 'concurso_test', idempotency_token: anything)
    @bot.receives('/activar_notificaciones')
  end

  def test_set_clarif_frequency
    set_contest
    @bot.receives('/cambiar_frecuencia_clarificaciones')
    @bot.expects(:send_message).with('Se va a actualizar cada 10 minutos.')
    @bot.receives('10')
  end

  def test_set_scoreboard_frequency
    set_contest
    @bot.receives('/cambiar_frecuencia_scoreboard')
    @bot.expects(:send_message).with('Se va a actualizar cada 10 minutos.')
    @bot.receives('10')
  end

  def test_toggle_clarif_notifications
    set_contest
    @bot.receives('/activar_notificaciones_clarificaciones')
    assert_nil(@bot.metadata[:mute_clarif])
    @bot.receives('/desactivar_notificaciones_clarificaciones')
    assert(@bot.metadata[:mute_clarif])
  end

  def test_toggle_scoreboard_notifications
    set_contest
    @bot.receives('/activar_notificaciones_scoreboard')
    assert_nil(@bot.metadata[:mute_scoreboard])
    @bot.receives('/desactivar_notificaciones_scoreboard')
    assert(@bot.metadata[:mute_scoreboard])
  end

  def test_deactivate_notifications
    set_contest
    @bot.save_metadata!
    @bot.receives('/activar_notificaciones')
    @bot.receives('/desactivar_notificaciones')
    assert_nil(@bot.metadata[:idempotency_token])
  end

  def test_contest_status
    set_contest
    @bot.metadata[:score_frequency] = 5
    @bot.metadata[:clarif_frequency] = 5
    @bot.save_metadata!
    @bot.expects(:send_message).with(<<~CONTEST
      concurso activo: concurso_test
      frecuencia notificaciones:
      * clarificaciones: 5 /cambiar_frecuencia_clarificaciones
      * score: 5 /cambiar_frecuencia_scoreboard
      /desactivar_notificaciones_clarificaciones
      /desactivar_notificaciones_scoreboard
      /desactivar_notificaciones
      /activar_notificaciones (reinicia el contador y dispara las notificaciones)
    CONTEST
                                    )
    @bot.receives('/contest')
  end

  def test_clarifications
    set_contest
    assert(@bot.metadata[:current_contest])
    @bot.dsl.expects(:fork_with_delay).returns(true)
    Omega::Contest.any_instance.expects(:clarifications).returns([SAMPLE_CLARIF])
    @bot.handle_job('contest_observer_clarif', { contest: 'concurso_test', idempotency_token: 123 }, @channel_id)
    OMEGAUPCLI.expects(:respond_clarif).with('123', '¿Cuál es el problema?')
    @bot.replies('¿Cuál es el problema?')
  end
end
