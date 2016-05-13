require 'csv'

class CsvImportingService
  attr_reader :file, :data, :user

  def initialize(file: file, user: user)
    @file, @user = file, user
  end

  def run
    begin
      read_csv
    rescue StandardError => e
      return { "error" => "#{e.class}: #{e.message}" }
    end

    data.map do |sprint|
      sprint = sprint.map{|k,v| [k.parameterize("_").to_sym, v]}
      sprint = OpenStruct.new Hash[sprint]
      sprint.user_id = @user.id
      sprint.digest = Digest::MD5.hexdigest sprint.to_s
      next if Sprint.where(digest: sprint.digest).exists?

      begin
        ActiveRecord::Base.transaction{ result = import_sprint sprint }
      rescue RuntimeError => e
        Rails.logger.warn "[ERROR]: #{e.message}"
      end
    end
    nil
  end

  private

  def import_sprint(data)
    params = extract_scenario_parameters(data.dungeon)
    raise "Unprocessable Dungeon Name: #{data.dungeon}" if params.blank?
    scenario = Scenario.send(params.delete(:level)).find_or_create_by(params)
    # scenario = Scenario.find_or_create_by(params)
    # binding.pry if scenario.new_record? && existing.map(&:to_s).include?(scenario.to_s)

    sprint = extract_sprint_parameters(data)
    sprint = scenario.sprints.create sprint
    raise sprint.errors.full_messages.join("\n") unless sprint.persisted?

    reward = sprint.create_reward extract_reward_parameters(data)
    raise reward.errors.full_messages.join("\n") unless reward.persisted?

    if reward.type == "Rune"
      rune = reward.create_rune extract_rune_parameters(data)
      raise rune.errors.full_messages.join("\n") unless rune.persisted?
    end

    sprint
  end

  def extract_rune_parameters(data)
    rune = {
      grade: data.rune_grade.to_i, sell_value: data.sell_value, 
      set: data.rune_set.underscore, efficiency: data.max_efficiency.to_f,
      slot: data.slot, rarity: data.rune_rarity.to_s.underscore,
      primary: data.main_stat, innate: data.prefix_stat,
      secondary1: data.secondary_stat_1, secondary2: data.secondary_stat_2,
      secondary3: data.secondary_stat_3, secondary4: data.secondary_stat_4
    }
    rune[:rarity] = :common if rune[:rarity].blank?
    rune
  end

  def extract_reward_parameters(data)
    # type = "Rune" if data.drop.downcase == "rune"
    if match = data.drop.match(/^(.*)\s+(\d+)\*$/)
      type, level, amount = match[1], match[2].to_i, 1
    elsif match = data.drop.match(/^(.*)\s+x(\d+)$/)
      type, level, amount = match[1], 0, match[2].to_i
    elsif data.drop.downcase == "rune"
      type, level, amount = "Rune", data[:rune_grade].to_i, 1
    elsif data.drop =~ /^unknown drop/i
      return {}
    else
      type, level, amount = data.drop, 0, 1
    end
    type = type.to_s.parameterize("_").camelize

    { type: type, amount: amount, level: level, mana: data.mana,
      crystal: data.crystal, energy: data.energy }
  end

  def extract_sprint_parameters(data)
    win = data.result.downcase == "win"
    h, time_taken = [1, 60, 3600], data.clear_time.split(":")
    time_taken = time_taken.reverse.map{|t| t.to_i * h.shift}.inject(&:+)
    started_at = Time.parse data.date

    { win: win, time_taken: time_taken, started_at: started_at,
      digest: data.digest, user_id: data.user_id }
  end

  def extract_scenario_parameters(dungeon)
    if match = dungeon.match(/^(.*)\s+b(\d+)$/i)
      { name: match[1], stage: match[2].to_i, level: "unknown" }
    elsif match = dungeon.match(/^(.*)\s+(Normal|Hard|Hell)\s+-\s+(\d+)$/)
      { name: match[1], stage: match[3].to_i, level: match[2].underscore }
    end
  end

  def read_csv
    text = File.read file.tempfile.path
    text = text.encode Encoding.find('ASCII'), invalid: :replace,
      undef: :replace, replace: '', universal_newline: true

    data = CSV.parse text
    keys = data.shift
    @data = data.map{|a| Hash[ keys.zip(a) ] }
  end
end
