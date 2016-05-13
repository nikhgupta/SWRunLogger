class ImportsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    @imports = Import.order(created_at: :desc).all
  end

  # TODO: file can be read just once, and text can be feed to import service
  def create
    copy_uploaded_file current_user, params['file'] if ENV['DEBUG']
    @import = CsvImportingService.new(file: params['file'], user: current_user).run

    if @import.persisted?
      render json: @import.to_json
    else
      render json: { error: "Import failed for some unknown reason!" }, status: :bad_request
    end
  rescue StandardError => e
    render json: { error: "#{e.class}: #{e.message}" }, status: :unsupported_media_type
  end

  private

  def log_file_for(user, file)
    Rails.root.join("data", "user-#{user.id}-#{Time.now.to_i}-#{file.original_filename}")
  end

  def copy_uploaded_file(user, file)
    File.open(log_file_for(user, file), "w") do |f|
      f.puts File.read(file.tempfile)
    end
  end
end
