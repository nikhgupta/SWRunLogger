namespace :sprints do

  desc "fix hash digests (unique IDs) for the sprints"
  task fix_digests: :environment do
    def digest(sprint)
      message  = sprint.reward.mana.to_s
      message += sprint.reward.crystal.to_s
      message += sprint.reward.energy.to_s
      message += "-"
      message += sprint.started_at.utc.to_i.to_s
      message += "-"
      message += sprint.scenario.to_s.downcase.gsub(/[^a-z0-9]/, '')
      message += (sprint.win? ? "win" : "lost")
      message += "-"
      message += sprint.import.user.id.to_s
      Digest::MD5.hexdigest message
    end

    seen = []
    sprints = Sprint.includes(:scenario, reward: :rune, import: :user)
    puts "Fixing digests on #{sprints.count} records"

    sprints.find_each do |sprint|
      digest = digest(sprint)

      if seen.include?(digest)
        puts "Found duplicate sprint with ID: #{sprint.id} - DROPPING IT!"
        sprint.reward.rune.try(:delete)
        sprint.reward.try(:delete)
        sprint.try(:delete)
      elsif sprint.digest != digest
        puts "Found invalid digest for sprint with ID: #{sprint.id} - UPDATING IT!"
        seen << digest
        sprint.update_attributes(digest: digest)
      end
    end
  end

end
