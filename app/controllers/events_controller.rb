class EventsController < ApplicationController
  before_action :assign_game

  def create
    service = SubmitEvent.new(@game, params)

    if service.call
      if service.respond_to?(:dice_rolled)
        flash.notice = service.dice_rolled
      end

      redirect_to game_path(@game, format: :json)
    else
      errors = service.errors.map { |error| I18n.t(error) }
      render json: { errors: errors }
    end
  end

  private

  def assign_game
    @game = Game.find(params[:game_id])
  end
end
