module Reporter
  class LogsReporter < BaseReporter
    private

    def process_or_cache_report
      sprints = @user_id ? User.find(@user_id).sprints : Sprint
      sprints = sprints.includes(:scenario, { reward: :rune }).all
      @report = sprints.map{|sprint| sanitize_for_display(sprint)}
    end

    def sanitize_for_display(sprint)
      {
        scenario: sprint.scenario.to_s,
        started_at: sprint.started_at.strftime("%H:%M %b %e, %Y"),
        duration: sprint.duration,
        # win: (sprint.win? ? "Yes" : "No"),
        mana: sprint.reward.mana,
        crystal: sprint.reward.crystal,
        energy: sprint.reward.energy,
        reward_type: sprint.reward.name,
        rune_slot: sprint.reward.rune.try(:slot),
        rune_rarity: sprint.reward.rune.try(:rarity),
        rune_value: sprint.reward.rune.try(:sell_value),
        rune_efficiency: sprint.reward.rune.try(:efficiency).round(2),
        # details: "<del style='color: #999'>Soon</del>"
      }
    end
  end
end
