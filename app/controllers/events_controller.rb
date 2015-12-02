class EventsController < ApplicationController
  before_action :assign_game

  def create
    service = SubmitEvent.new(@game, params)

    unless service.call
      flash.alert = service.errors
    end

    redirect_to @game
  end

  private

  def assign_game
    @game = Game.find(params[:game_id])
  end
end
