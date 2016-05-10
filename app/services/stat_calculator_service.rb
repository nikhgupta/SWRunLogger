class StatCalculatorService
  def initialize(records)
    @records = records
  end

  def run
    grouped = @records.group_by(&:scenario).map do |scenario, sprints|
      @sprints = sprints
      data = [scenario, statistics]
      @sprints = nil
      data
    end

    Hash[grouped]
    # add_row_and_column_headers Hash[grouped]
  end

  private

  def add_row_and_column_headers(grouped)
    cols = grouped.keys.map(&:to_s)
    rows = grouped.each_pair.map{|sc, st| st[:totals].keys}.
      flatten.uniq.
      sort_by{|a| a.split(" ", 2).reverse}

    { data: grouped, rows: rows, cols: cols }
  end

  def rewards
    @sprints.map(&:reward)
  end

  def runes
    @sprints.map{|sprint| sprint.reward.rune}.compact
  end

  def records
    { sprints: @sprints, rewards: rewards, runes: runes }
  end

  def averages
    data = {
      time_taken: nil, mana: :reward, crystal: :reward, energy: :reward,
      sell_value: [:reward, :rune], efficiency: [:reward, :rune]
    }.map do |field, keys|
      [field, @sprints.average_for(*([keys].flatten << field).compact)]
    end

    Hash[data]
  end

  # def totals
  #   rewards = @sprints.map(&:reward).group_by(&:name_without_amount)
  #   rewards = rewards.map{|name,r1| [name, r1.map(&:amount).sum]}
  #   Hash[rewards]
  # end

  def reward_totals
    rewards = @sprints.map(&:reward).group_by(&:classification).map do |klass, r1|
      r1 = r1.group_by(&:level)
      r1 = r1.map do |level, r2|
        [level, {
          count: r2.map(&:amount).sum,
          value: r2.map{|rr| rr.rune.try(:sell_value) }.average.to_i,
          efficiency: r2.map{|rr| rr.rune.try(:efficiency) }.average,
          average: (r2.map(&:amount).sum.to_f/@sprints.count.to_f*100)
        }]
      end
      [klass, Hash[r1]]
    end
    Hash[rewards]
  end

  def totals
    { rewards: reward_totals, runs: @sprints.count }
  end

  def statistics
    { averages: averages, totals: totals } #, records: records }
  end
end
