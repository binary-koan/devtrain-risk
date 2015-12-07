class EventsController < ApplicationController
  before_action :assign_game

  def create
    service = SubmitEvent.new(@game, params)

    flash.alert = service.errors unless service.call

    redirect_to @game
  end

  private

  def assign_game
    @game = Game.find(params[:game_id])
  end
end
