class ComparisonReporter
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(user_id = nil)
    sprints = user_id ? User.find(user_id).sprints : Sprint.all
    User.pluck(:id).map{|id| self.class.perform_async id} if user_id.blank?

    name = user_id.blank? ? "global" : user_id
    file = Rails.root.join("data", "reports", "comparison", "#{name}.json")
    file.dirname.mkpath unless file.dirname.exist?

    return if file.exist? && file.stat.mtime > 4.hours.ago
    report  = sprints.statistics

    file.open("w"){|f| f.puts report.to_json}

    store user: user_id
    store path: file.to_s
  end
end
