class ServicesController < ApplicationController
  before_action :set_job_id, only: [:job_status]

  def job_status
    data = Sidekiq::Status.get_all(@job_id)
    data["status"]  = data["status"].titleize if data["status"]
    data["percent"] = (data["at"].to_f / data["total"].to_f * 100).round(2) if data["total"].present?
    data["status"]  = "Failed" if data['failed'] == "1" || data['error'].present?
    render json: data.to_json
  end

  private

  def set_job_id
    @job_id = params[:job_id]
  end
end
