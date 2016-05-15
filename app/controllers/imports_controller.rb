class ImportsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    @imports = Import.order(created_at: :desc).all
  end

  # We can add JobID to @import object directly.
  def create
    job_id  = CsvImporter.perform_async current_user.id, params['file'].tempfile.path

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Successfully queued.." }
      format.json { render json: { job_id: job_id } }
    end
  end
end
