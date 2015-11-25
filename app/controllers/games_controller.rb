class GamesController < ApplicationController
  def new
  end

  def create
    create_game = CreateGame.new
    game = create_game.call
    if game
      redirect_to game
    else
      flash.alert = create_game.errors
      redirect_to :back
    end
  end

  def show
    @game = Game.find(params[:id])
  end
end
