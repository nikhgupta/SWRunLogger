class BatchPerformer
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  class << self
    attr_reader :jobs

    def in_batch_perform(klass, *args)
      jid = klass.to_s.constantize.perform_async(*args)
      @jobs ||= {}
      @jobs[jid] = klass
    end

    def batch_data
      data = @jobs.map do |jid, klass|
        [jid, { class: klass, data: Sidekiq::Status::get_all(jid) }]
      end
      Hash[data]
    end

    def batch_status
      Hash[batch_data.map{|jid, data| [jid, data[:data][:status]]}]
    end

    def batch_progress
      Hash[batch_status.values.group_by(&:itself).map{|k,v| [k, v.count]}]
    end
  end

  def in_batch_perform(*args)
    self.class.in_batch_perform(*args)
  end
end
