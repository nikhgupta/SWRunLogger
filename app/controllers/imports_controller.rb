class ImportsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def create
    response = CsvImportingService.new(file: params['file'], user: current_user).run
    if response && response.respond_to?(:has_key?) && response['error'].present?
      render json: { error: response['error'] }, status: :unsupported_media_type
    else
      render nothing: true
    end
  end
end
