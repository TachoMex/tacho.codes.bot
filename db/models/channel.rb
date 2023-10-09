class Channel < ActiveRecord::Base
  belongs_to :user

  validates :adapter, presence: true, length: { maximum: 16 }
  validates :channel_id, presence: true, length: { maximum: 128 }
end
