class SubmitEvent
  attr_reader :errors

  def initialize(game, params)
    @game = game
    @params = params
    @errors = []
  end

  def call
    case @params[:event][:event_type]
    when "attack"
      perform_attack
    when "fortify"
      perform_fortify
    when "reinforce"
      perform_reinforce
    when "start_turn"
      end_turn
    else
      @errors << :unknown_event_type
    end

    @errors.none?
  end

  private

  def perform_attack
    service = PerformAttack.new(
      territory_from: @game.territories[@params[:from]],
      territory_to: @game.territories[@params[:to]],
      game_state: GameState.new(@game)
    )
    service.call
    @errors = service.errors
  end

  def perform_fortify
    service = PerformFortify.new(
      territory_from: @game.territories[@params[:from]],
      territory_to: @game.territories[@params[:to]],
      game_state: GameState.new(@game),
      fortifying_units: @params[:units]
    )
    service.call
    @errors = service.errors
  end

  def perform_reinforce
    fail "Reinforcement isn't implemented yet" #TODO
  end

  def end_turn
    EndTurn.new(@game).call
  end
end
