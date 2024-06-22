module OmegaupHelpers
  def add_user_to_contest(user, contest)
    OMEGAUPCLI.add_user_to_contest(user, contest)
  end
end