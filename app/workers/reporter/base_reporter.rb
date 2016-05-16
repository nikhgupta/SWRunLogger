module Reporter
  class BaseReporter
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform(user_id = nil, force = nil)
      @user_id = user_id
      enqueue_all_users

      return if data_file.exist? && data_file.stat.mtime > 4.hours.ago && !force

      process_or_cache_report
      data_file.open("w"){|f| f.puts @report.to_json }

      store user: @user_id
      store path: data_file.to_s
    end

    protected

    def enqueue_all_users
      return if @user_id.present?
      User.pluck(:id).map{|id| self.class.perform_async id}
    end

    def report_type
      self.class.name.demodulize.underscore.gsub(/_reporter$/, '')
    end

    def data_file
      return @file if @file.present?

      name = @user_id.blank? || @user_id == "global" ? "global" : @user_id
      @file = Rails.root.join("data", "reports", report_type, "#{name}.json")
      @file.dirname.mkpath unless @file.dirname.exist?
      @file
    end
  end
end
