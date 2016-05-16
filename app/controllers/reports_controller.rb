class ReportsController < ApplicationController
  before_action :disable_per_user_cache, only: [:logs]
  before_action :enqueue_or_read_report

  def logs
    respond_to do |format|
      format.html
      if @job_id.present?
        format.json { render json: { job_id: @job_id }.to_json }
      else
        format.json { render json: @data.map(&:values).to_json }
      end
    end
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
    render_html_or_json
  end

  private

  def render_html_or_json
    respond_to do |format|
      format.html
      format.json { render json: { job_id: @job_id, data: @data }.to_json }
    end
  end

  def disable_per_user_cache
    @per_user_cache = false
  end

  def enqueue_or_read_report
    @per_user_cache = true if @per_user_cache.nil?

    if data_file.present?
      @data = JSON.load data_file.read
    else
      job = "reporter/#{action_name}_reporter".camelize.constantize
      @job_id = job.perform_async current_user.try(:id)
    end
  end

  def data_file
    return if !@per_user_cache && current_user.present?
    return @file if @file.present?
    user = current_user ? current_user.id : "global"
    @file = Rails.root.join("data", "reports", action_name, "#{user}.json")
    @file if @file.exist? && @file.stat.mtime > 4.hours.ago
  end
end
