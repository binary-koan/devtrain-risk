class GamesController < ApplicationController
  before_action :assign_game, except: [:new, :create]

  def new
  end

  def create
    game = CreateGame.new.call
    redirect_to game
  end

  def show
    @game_state = GameState.current(@game)
  end

  private

  def assign_game
    @game = Game.find(params[:id])
  end
end
