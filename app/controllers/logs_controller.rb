class LogsController < ApplicationController
  def index
    @sprints = current_user ? current_user.sprints : Sprint
    @sprints = @sprints.includes(:scenario, { reward: :rune }).all
  end
end
