class Sprint < ActiveRecord::Base
  belongs_to :user
  belongs_to :scenario

  has_one :reward
  has_one :rune, through: :reward

  validates :digest, uniqueness: true

  def to_s
    "#{scenario} @ #{started_at}"
  end

  def duration
    Time.at(time_taken).utc.strftime("%H:%M:%S")
  end

  def self.statistics
    all = includes(:scenario, { reward: :rune })
    StatCalculatorService.new(all).run
  end
end
