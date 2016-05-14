class Sprint < ActiveRecord::Base
  belongs_to :scenario
  belongs_to :import

  has_one :reward
  has_one :rune, through: :reward

  validates :digest, uniqueness: true

  delegate :user, to: :import

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
