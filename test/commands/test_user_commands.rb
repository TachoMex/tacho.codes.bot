# frozen_string_literal: true

require './test/test_helper'

module Charrobot
  class TestUserCommands < BotTest
    def test_default_command
      @bot.expects(:send_message).twice
      @bot.receives('something not in commands')
    end

    def test_register_user
      assert_difference('User.count') do
        @bot.receives('/iniciar')
      end

      @bot.expects(:send_message).with('Ya has iniciado el bot. /help te mostrará la ayuda.')
      @bot.receives('/iniciar')
    end

    def test_set_data
      { omegaup_username: 'usuario_omegaup', country: 'pais', state: 'estado', school: 'escuela' }.each do |symbol, name|
        user = register_user
        assert_nil(user[symbol])
        @bot.receives("/agregar_#{name}test")
        newuser = User.last
        assert_equal('test', newuser[symbol])
      end
    end

    def test_add_date_of_birth
      user = register_user
      assert_nil(user.date_of_birth)
      @bot.receives('/agregar_fecha_de_nacimiento')
      @bot.receives('2000')
      @bot.receives('01')
      @bot.receives('01')
      newuser = User.last
      assert_equal(newuser.date_of_birth, Date.new(2000, 1, 1))
    end
   
    def test_add_date_of_birth_wrong_date
      user = register_user
      assert_nil(user.date_of_birth)
      @bot.receives('/agregar_fecha_de_nacimiento')
      @bot.receives('2000')
      @bot.receives('02')
      @bot.receives('31')
      newuser = User.last
      assert_nil(newuser.date_of_birth)
    end
    
    def test_set_configs
      { cpp_coder: 'aprender_cpp', karel_coder: 'aprender_karel', allow_newsletter: 'recibir_anuncios'}.each do |symbol, name|
        user = register_user
        assert_nil(user[symbol])
        @bot.receives("/quiero_#{name}")
        newuser = User.last
        assert(newuser[symbol])
        @bot.receives("/ya_no_quiero_#{name}")
        newuser = User.last
        refute(newuser[symbol])
      end
    end
  end
end
