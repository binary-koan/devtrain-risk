class GamesController < ApplicationController
  def new
  end

  def create
    game = CreateGame.new.call
    redirect_to game
  rescue ActiveRecord::ActiveRecordError => e
    flash.alert = e.message
    redirect_to :back
  end

  def show
    @game = Game.find(params[:id])
    @state = GameState.new(@game)
  end

  def territory_info
    game = Game.find(params[:id])
    state = GameState.new(game)

    render json: {
      territories: state.territories,
      territory_links: state.territory_links,
      players: state.players
    }
  end
end
