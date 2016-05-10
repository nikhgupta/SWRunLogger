class Rune < ActiveRecord::Base
  belongs_to :reward

  validates :reward_id, uniqueness: true

  delegate :sprint, :scenario, :user, to: :reward

  enum rarity: { common: 0, magic: 3, rare: 60, hero: 90, legendary: 120 }

  enum set: {
    despair: 10, energy: 20, fatal: 30, blade: 40, swift: 50,
    violent: 60, focus: 70, guard: 80, endure: 90, shield: 100, revenge: 110,
    rage: 120, will: 130, nemesis: 140, vampire: 150, destroyer: 160
  }

  def name
    "#{grade}* #{set}" + (common? ? "" : " - #{rarity}")
  end

  def rarity
    super.titleize
  end

  def set
    destroyer? ? "Destroy" : super.titleize
  end
end
