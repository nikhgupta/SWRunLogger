class ReportsController < ApplicationController
  def comparison
    file = data_file_for(:comparison)

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

    if file.present?
      @data = JSON.load file.read
    else
      @job_id = ComparisonReporter.perform_async current_user.try(:id)
    end
    # @job_id = ComparisonReporter.perform_async current_user.try(:id)

    respond_to do |format|
      format.html
      format.json { render json: { job_id: @job_id, data: @data } }
    end
  end

  private

  def data_file_for(report)
    user = current_user ? current_user.id : "global"
    file = Rails.root.join("data", "reports", report.to_s, "#{user}.json")
    file if file.exist? && file.stat.mtime > 4.hours.ago
  end
end
