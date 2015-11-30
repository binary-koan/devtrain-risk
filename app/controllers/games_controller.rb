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
    serializer = TerritoryInfoJson.new(state)

    render json: {
      territories: serializer.territories,
      territoryLinks: serializer.territory_links
    }
  end

  def event
    json = handle_event
    render json: json
  end

  private

  def assign_game
    @game = Game.find(params[:id])
  end

  def handle_event
    service = PerformAttack.new(attack_params)
    event = service.call

    if event
      actions = event.actions.map do |action|
        {
          territoryIndex: @game.territories.find_index(action.territory),
          ownerIndex: @game.players.find_index(action.territory_owner),
          units: action.units_difference
        }
      end
      { actions: actions }
    else
      { errors: service.errors }
    end
  end

  def attack_params
    {
      territory_from: Territory.find(params[:from].to_i),
      territory_to: Territory.find(params[:to].to_i),
      game_state: GameState.new(@game)
    }
  end
end
