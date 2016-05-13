class ImportsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    @imports = Import.order(created_at: :desc).all
  end

  def create
    @import = CsvImportingService.new(file: params['file'], user: current_user).run

    if @import.persisted?
      render json: @import.to_json
    else
      render json: { error: "Import failed for some unknown reason!" }, status: :bad_request
    end
  rescue StandardError => e
    render json: { error: "#{e.class}: #{e.message}" }, status: :unsupported_media_type
  end
end
