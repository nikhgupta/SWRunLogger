class ReportsController < ApplicationController
  before_action :enqueue_or_read_report

  def logs
    @data = @data.map(&:values) if @data.present?
    render_job_id_or_json
  end

  def comparison
    @tabs = {
      runes: %w(
        energy blade fatal swift despair
        violent focus guard endure shield revenge
        rage will nemesis vampire destroy
      ),
      drops: %w( rainbowmon),
    }
    @miscelleneous = %w(
      unknown_scroll mystical_scroll
      summoning_stones shapeshift_stone
    )
    render_job_id_or_json
  end

  private

  def render_job_id_or_json
    respond_to do |format|
      format.html

      if @job_id.present?
        format.json { render json: { job_id: @job_id }.to_json }
      else
        format.json { render json: @data.to_json }
      end
    end
  end

  def enqueue_or_read_report
    if data_file.present?
      @data = JSON.load data_file.read
    else
      job = "reporter/#{action_name}_reporter".camelize.constantize
      @job_id = job.perform_async current_user.try(:id)
    end
  end

  def data_file
    return @file if @file.present?
    user = current_user ? current_user.id : "global"
    @file = Rails.root.join("data", "reports", action_name, "#{user}.json")
    @file if @file.exist? && @file.stat.mtime > 4.hours.ago
  end
end
