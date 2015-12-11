class GamesController < ApplicationController
  before_action :assign_game, except: [:new, :create]

  def new
  end

  def create
    service = CreateGame.new(map_name: map_name)
    game = service.call

    if game.present? && game.errors.empty?
      redirect_to game
    else
      flash.alert = service.errors
      redirect_to :back
    end
  end

  def show
    @turn = BuildTurn.new(@game.events).call
  end

  private

  def map_name
    params.require(:map_name)
  end

  def assign_game
    @game = Game.find(params[:id])
  end
end
