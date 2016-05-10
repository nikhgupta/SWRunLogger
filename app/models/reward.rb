class Reward < ActiveRecord::Base
  self.inheritance_column = false

  validates :sprint_id, uniqueness: true

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
    if level > 0 && amount > 1
      "#{level}* #{type.titleize} x#{amount}"
    elsif level > 0
      "#{level}* #{type.titleize}"
    else
      "#{type.titleize} x#{amount}"
    end
  end
end
