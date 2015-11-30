class GamesController < ApplicationController
  before_action :assign_game, except: [:new, :create]

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

  def state
    state = GameState.new(@game)
    serializer = GameStateJson.new(state)

    render json: { state: serializer.json }
  end

  def event
    json = handle_event
    render json: json
  end

  def end_turn
    EndTurn.new(@game).call
    render json: { errors: false }
  end

  private

  def assign_game
    @game = Game.find(params[:id])
  end

  def handle_event
    service = PerformAttack.new(attack_params)

    if service.call
      { errors: false }
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
