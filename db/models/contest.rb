class Contest < ActiveRecord::Base
  has_many :user_contest_relationships
  has_many :users, through: :user_contest_relationships

  validates :short_name, presence: true, length: { maximum: 32 }, uniqueness: true
  validates :name, presence: true, length: { maximum: 64 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :topic, length: { maximum: 64 }

  validates :karel, inclusion: { in: [true, false] }
  validates :cpp, inclusion: { in: [true, false] }

  def omegaup_url
    "https://omegaup.com/arena/#{short_name}"
  end

  def to_message_format
    <<~CONTEST
      Concurso: #{name}
      #{omegaup_url}
      Inicia: #{start_time}
      Termina: #{end_time}
      Lenguaje: #{karel ? 'Karel' : 'C++'}
      Tópico: #{topic}
      #{description}
      /ver_concurso#{id}
    CONTEST
  end
end
