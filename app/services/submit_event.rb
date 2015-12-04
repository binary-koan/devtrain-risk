class SubmitEvent
  attr_reader :errors

  def initialize(game, params)
    @game = game
    @params = params
    @errors = []
  end

  def call
    service = case @params[:event][:event_type]
    when "attack"
      perform_attack
    when "fortify"
      perform_fortify
    when "reinforce"
      perform_reinforce
    when "start_turn"
      end_turn
    end

    if !service
      @errors << :unknown_event_type
      false
    elsif !service.call
      @errors += service.errors
      false
    else
      true
    end
  end

  private

  def perform_attack
    PerformAttack.new(
      territory_from: @game.territories[@params[:from].to_i],
      territory_to: @game.territories[@params[:to].to_i],
      game_state: GameState.current(@game)
    )
  end

  def perform_fortify
    PerformFortify.new(
      territory_from: @game.territories[@params[:from].to_i],
      territory_to: @game.territories[@params[:to].to_i],
      game_state: GameState.current(@game),
      fortifying_units: @params[:units].to_i
    )
  end

  def perform_reinforce
    fail "Reinforcement isn't implemented yet" #TODO
  end

  def end_turn
    EndTurn.new(@game)
  end
end
