class GamesController < ApplicationController
  before_action :assign_game, only: [:show, :territory_info]

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
    @state = GameState.new(@game)
  end

  def territory_info
    state = GameState.new(@game)
    serializer = GameStateJson.new(state)

    render json: {
      territories: serializer.territories,
      territory_links: serializer.territory_links,
      players: serializer.players
    }
  end

  private

  def assign_game
    @game = Game.find(params[:id])
  end
end
