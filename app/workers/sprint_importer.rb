class SprintImporter
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(import_id, data)
    @data = data
    @import = Import.includes(:user).find import_id

    sanitize_sprint_data
    add_digest_to_sprint_data

    return :existing if sprint_exists?
    ActiveRecord::Base.transaction{ migrate_sprint_data }
    :saved
  rescue StandardError => e
    Rails.logger.warn "[ERROR]: #{e.class} => #{e.message}"
    Rails.logger.warn "[BACKTRACE]: #{e.backtrace.join("\n             ")}"
    :faulty
  end

  private

  def migrate_sprint_data
    parse_and_migrate_scenario
    parse_and_migrate_sprint
    parse_and_migrate_reward

    return unless @reward.type.downcase.to_sym == :rune
    parse_and_migrate_rune
  end

  def sanitize_sprint_data
    @data = @data.map{|k,v| [k.parameterize("_").to_sym, v]}
    @data = OpenStruct.new Hash[@data]
  end

  def add_digest_to_sprint_data
    @data.user_id = @import.user.id
    @data.digest = Digest::MD5.hexdigest @data.to_s.inspect
  end

  def sprint_exists?
    Sprint.where(digest: @data.digest).exists?
  end

  def parse_and_migrate_scenario
    scenario = nil
    if match = @data.dungeon.match(/^(.*)\s+b(\d+)$/i)
      scenario = { name: match[1], stage: match[2].to_i, level: "unknown" }
    elsif match = @data.dungeon.match(/^(.*)\s+(Normal|Hard|Hell)\s+-\s+(\d+)$/)
      scenario = { name: match[1], stage: match[3].to_i, level: match[2].underscore }
    end

    raise "Unprocessable Dungeon Name: #{@data.dungeon}" if scenario.blank?
    @scenario = Scenario.send(scenario.delete(:level)).find_or_create_by(scenario)
    raise_validation_errors_if_any! @scenario
  end

  def parse_and_migrate_sprint
    win = @data.result.downcase == "win"
    h, time_taken = [1, 60, 3600], @data.clear_time.split(":")
    time_taken = time_taken.reverse.map{|t| t.to_i * h.shift}.inject(&:+)
    started_at = Time.parse @data.date

    @sprint = @import.sprints.create scenario_id: @scenario.id, win: win,
      digest: @data.digest, time_taken: time_taken, started_at: started_at

    raise_validation_errors_if_any! @sprint
  end

  def parse_and_migrate_reward
    if match = @data.drop.match(/^(.*)\s+(\d+)\*$/)
      type, level, amount = match[1], match[2].to_i, 1
    elsif match = @data.drop.match(/^(.*)\s+x(\d+)$/)
      type, level, amount = match[1], 0, match[2].to_i
    elsif @data.drop.downcase == "rune"
      type, level, amount = "Rune", @data.rune_grade.to_i, 1
    elsif @data.drop =~ /^unknown drop/i
      type, level, amount = "Unknown Drop", 0, 1
    else
      type, level, amount = @data.drop, 0, 1
    end
    type = type.to_s.parameterize("_").camelize

    @reward = @sprint.create_reward type: type, amount: amount,
      level: level, mana: @data.mana, crystal: @data.crystal,
      energy: @data.energy

    raise_validation_errors_if_any! @reward
  end

  def parse_and_migrate_rune
    rarity = @data.rune_rarity.to_s.underscore
    rarity = :common if rarity.blank?

    @rune = @reward.create_rune(
      slot:       @data.slot,
      set:        @data.rune_set.underscore,
      grade:      @data.rune_grade.to_i,
      innate:     @data.prefix_stat,
      rarity:     rarity,
      primary:    @data.main_stat,
      sell_value: @data.sell_value, 
      efficiency: @data.max_efficiency.to_f,
      secondary1: @data.secondary_stat_1,
      secondary2: @data.secondary_stat_2,
      secondary3: @data.secondary_stat_3,
      secondary4: @data.secondary_stat_4
    )

    raise_validation_errors_if_any! @rune
  end

  def raise_validation_errors_if_any!(record)
    raise record.errors.full_messages.join("\n") unless record.persisted?
    record
  end
end
