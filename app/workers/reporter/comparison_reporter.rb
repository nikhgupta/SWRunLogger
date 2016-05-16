module Reporter
  class ComparisonReporter < BaseReporter
    def process_or_cache_report
      sprints = @user_id ? User.find(@user_id).sprints : Sprint
      @report = sprints.all.statistics
    end
  end
end
