class Reward < ActiveRecord::Base
  self.inheritance_column = false

  validates :sprint_id, uniqueness: true
  validates :type, presence: true

  belongs_to :sprint
  has_one :rune

  delegate :scenario, :user, to: :sprint

  def classification
    rune? ? rune.set : type.titleize
  end

  def name_without_amount
    text = rune? ? rune.set : type.titleize
    level > 0 ? "#{level}* #{text}" : text
  end

  def rune?
    type == "Rune"
  end

  def name
    if level.to_i > 0 && amount.to_i > 1
      "#{level}* #{type.titleize} x#{amount}"
    elsif level.to_i > 0
      "#{level}* #{type.titleize}"
    else
      "#{type.to_s.titleize} x#{amount}"
    end
  end
end
