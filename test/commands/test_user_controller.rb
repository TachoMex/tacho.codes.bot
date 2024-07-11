# frozen_string_literal: true

require_relative '../test_helper'

class TestUserController < BotTest
  def test_register_user
    @bot.receives('/iniciar')
    assert(@bot.metadata[:started])
    @bot.expects(:send_message).with('Ya has iniciado el bot. /help te mostrará la ayuda.')
    @bot.receives('/iniciar')
  end

  def test_bot_has_help_command
    @bot.receives('/help')
  end

  def test_set_data
    { omegaup_username: 'usuario_omegaup', country: 'pais', state: 'estado',
      school: 'escuela' }.each do |symbol, name|
      @bot.receives('/iniciar')
      assert_nil(@bot.metadata[symbol])
      @bot.receives("/agregar_#{name}test")

      assert_equal('test', @bot.metadata[symbol])
    end
  end

  def test_add_date_of_birth
    @bot.receives('/iniciar')
    assert_nil(@bot.metadata[:date_of_birth])
    @bot.receives('/agregar_fecha_de_nacimiento')
    @bot.receives('2000')
    @bot.receives('01')
    @bot.receives('01')
    assert_equal(@bot.metadata[:date_of_birth], Date.new(2000, 1, 1).to_s)
  end

  def test_add_date_of_birth_wrong_date
    @bot.receives('/iniciar')
    assert_nil(@bot.metadata[:date_of_birth])
    @bot.receives('/agregar_fecha_de_nacimiento')
    @bot.receives('2000')
    @bot.receives('02')
    @bot.receives('31')
    assert_nil(@bot.metadata[:date_of_birth])
  end

  def test_set_configs
    @bot.receives('/iniciar')
    { cpp_coder: 'aprender_cpp', karel_coder: 'aprender_karel', allow_newsletter: 'recibir_anuncios',
      problem_tagger: 'clasificar_problemas' }.each do |symbol, name|
      assert_nil(@bot.metadata[symbol])
      @bot.receives("/quiero_#{name}")
      assert(@bot.metadata[symbol])
      @bot.receives("/ya_no_quiero_#{name}")
      refute(@bot.metadata[symbol])
    end
  end
end
