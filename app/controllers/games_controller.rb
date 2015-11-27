class GamesController < ApplicationController
  before_action :assign_game, only: [:show, :territory_info, :event]

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
      territoryLinks: serializer.territory_links,
      players: serializer.players
    }
  end

  def event
    #TODO
    # service = PerformAttack.new
    # event = service.call
    # if event
    #   #TODO serializer
    #   render json: { actions: event.actions.select("territory_id, territory_owner_id, units_difference") }
    # else
    #   render json: { errors: service.errors }
    # end

    render json: {
      actions: [
        { territoryIndex: 0, units: -2, ownerIndex: 0 },
        { territoryIndex: 1, units: 2, ownerIndex: 1 }
      ]
    }
  end

  private

  def assign_game
    @game = Game.find(params[:id])
  end
end
