class GamesController < ApplicationController
  def new
  end

  def create
    game = CreateGame.new.call
    redirect_to game
  rescue CreateGame::Error => e
    flash.alert = e.message
    redirect_to :back
  end

  def show
    @game = Game.find(params[:id])
  end
end
