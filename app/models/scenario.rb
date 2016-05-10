class Scenario < ActiveRecord::Base
  has_many :sprints
  has_many :rewards, through: :sprints
  has_many :runes, through: :rewards

  enum level: { unknown: 0, normal: 1, hard: 2, hell: 3 }

  validates :name, uniqueness: { scope: [:level, :stage] }

  def to_s
    unknown? ? "#{name} B#{stage}" : "#{name} (#{level}) - #{stage}"
  end

  def level
    super.titleize
  end

  # def average_runtime(duration: false)
  #   times = self.sprints.pluck(:time_taken)
  #   times = (times.inject(&:+) / times.count.to_f).round(2)
  #   duration ? Time.at(times).utc.strftime("%H:%M:%S") : times
  # end

  # def average_gains
  #   keys = %w(mana crystal energy)
  #   Hash[keys.map do |key|
  #     data = self.rewards.pluck(key)
  #     data = (data.inject(&:+) / data.count.to_f).round(2)
  #     [key.to_sym, data]
  #   end]
  # end

  # def average_rune_sell_value
  #   data = self.runes.pluck(:sell_value)
  #   (data.inject(&:+) / data.count.to_f).round(2)
  # end

  # def total_items
  #   rewards = self.rewards.order(:type, :level).map do |reward|
  #     ["#{reward.level > 0 ? "#{reward.level}*" : ""} #{reward.type.titleize}".strip, reward.amount]
  #   end
  #   rewards = rewards.group_by(&:itself).map{|k,v| [k.first, v.map(&:last).sum]}
  #   rewards = Hash[rewards]
  # end

  # def average_items
  #   Hash[total_items.map{|k,v| [k, (v.to_f/self.sprints.count*100).round(2)]}]
  # end

  # def averages
  #   {
  #     time_taken: average_runtime,
  #     rune_sell_value: average_rune_sell_value
  #   }.merge(average_gains).merge(total_runs: self.sprints.count, items: average_items)
  # end
end
