# frozen_string_literal: true

require './test/test_helper'

module Charrobot
  class TestContestCommands < BotTest
    def add_contest(short_name = 'shortname', admin = true)
      user = register_user
      user.admin = admin
      user.save!
      Omega::Client.any_instance.expects(:create_contest) if admin
      @bot.receives('/agregar_concurso')
      @bot.receives('Some contest')
      @bot.receives(short_name)
      @bot.receives('/cpp')
      @bot.receives('cin/cout')
      @bot.receives(Time.now.yesterday.to_s)
      @bot.receives(Time.now.tomorrow.to_s)
      @bot.receives('test description')
      Contest.find_by(short_name:)
    end

    def test_add_contest
      assert_difference('Contest.count') do
        contest = add_contest
        assert_equal('shortname', contest.short_name)
        assert(contest.cpp)
        refute(contest.karel)
      end
    end

    def test_non_admin_user_cant_add_contest
      refute_difference('Contest.count') do
        add_contest('nonadmin', false)
      end
    end

    def test_register_to_contest
      contest = add_contest('othercontest')
      @bot.receives("/quiero_participar#{contest.id}")
      user = User.last
      refute(user.contests.include?(contest))
      @bot.receives('/agregar_usuario_omegauptest')

      @bot.expects(:send_message).with(regexp_matches(/No estás registrado a ningún concurso/)).once
      @bot.receives('/mis_concursos')

      @bot.expects(:send_message).with(regexp_matches(/\/ver_concurso/)).once
      @bot.receives('/proximos_concursos')

      @bot.expects(:send_message).with(regexp_matches(/El usuario ha sido registrado en el concurso./)).once
      Omega::Client.any_instance.expects(:add_user_to_contest).with('test', 'othercontest')
      @bot.receives("/quiero_participar#{contest.id}")
      assert(user.contests.include?(contest))

      Omega::Client.any_instance.expects(:add_user_to_contest).never

      @bot.expects(:send_message).with(regexp_matches(/\/ver_concurso/)).once
      @bot.receives('/mis_concursos')

      @bot.expects(:send_message).with(regexp_matches(/El usuario ya está registrado/)).once
      @bot.receives("/quiero_participar#{contest.id}")

      @bot.expects(:send_message).with('El concurso no existe')
      @bot.receives('/quiero_participarnonexistent')
    end

    def test_no_initialization
      @bot.expects(:redirect).with('/help')
      @bot.receives('/proximos_concursos')
    end


    def test_no_contests_to_show
      register_user
      @bot.expects(:send_message).with(regexp_matches(/No hay concursos próximos/)).once
      @bot.receives('/proximos_concursos')
    end

    def test_view_contest
      contest = add_contest('viewcontest')
      @bot.expects(:send_message).with(regexp_matches(%r{omegaup.com/arena/viewcontest}))
      @bot.receives("/ver_concurso#{contest.id}")
      @bot.expects(:send_message).with('El concurso no existe')
      @bot.receives('/ver_concursounexistent')
    end
  end
end
