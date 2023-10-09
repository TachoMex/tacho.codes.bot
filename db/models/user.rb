class User < ActiveRecord::Base
  has_many :channels
  has_many :user_contest_relationships
  has_many :contests, through: :user_contest_relationships

  validates :omegaup_username, length: { maximum: 50 }
  validates :country, :state, :city, length: { maximum: 50 }
  validates :email, length: { maximum: 100 }

  def active_contests
    contests.where('end_time >= ?', Time.now)
  end
end
