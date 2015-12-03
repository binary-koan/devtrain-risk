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
    @game_state = GameState.current(@game)
  end

  def event
    handle_event
    redirect_to @game
  end

  def end_turn
    EndTurn.new(@game).call
    redirect_to @game
  end

  private

  def assign_game
    @game = Game.find(params[:id])
  end

  def handle_event
    service = PerformAttack.new(attack_params)

    unless service.call
      flash.alert = service.errors
    end
  end

  def attack_params
    {
      territory_from: @game.territories[params[:from].to_i],
      territory_to: @game.territories[params[:to].to_i],
      game_state: GameState.new(@game)
    }
  end
end
