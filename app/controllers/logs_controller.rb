class LogsController < ApplicationController
  def index
    @sprints = current_user ? current_user.sprints : Sprint
    @sprints = @sprints.includes(:scenario, { reward: :rune }).all

    # respond_to do |format|
    #   format.html
    #   format.json { render json: @sprints.to_json }
    # end
  end

  def compare
    sprints = current_user ? current_user.sprints : Sprint.all
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
    @statistics = sprints.statistics
  end
end

