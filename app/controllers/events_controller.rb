class EventsController < ApplicationController
  before_action :assign_game

  def create
    dice_roller = DiceRoller.new
    service = SubmitEvent.new(@game, dice_roller, params)

    if service.call
      if dice_roller.rolls.any?
        flash.notice = dice_roller.rolls
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
