json.array! @sprints do |sprint|
  json.array! [
    sprint.scenario.to_s,
    sprint.started_at.strftime("%H:%M %b %e, %Y"),
    sprint.duration,
    sprint.reward.mana,
    sprint.reward.crystal,
    sprint.reward.energy,
    sprint.reward.name,
    sprint.reward.rune.try(:slot),
    sprint.reward.rune.try(:rarity),
    number_with_delimiter(sprint.reward.rune.try(:sell_value)),
    number_to_percentage(sprint.reward.rune.try(:efficiency), precision: 2),
    "<del style='color: #999'>Soon</del>"
  ]
end
