class SubmitEvent
  attr_reader :errors

  def initialize(game, params)
    @game = game
    @game_state = BuildGameState.new(@game, @game.events).call
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
      game_state: @game_state,
      attacking_units: @params[:units].to_i
    )
  end

  def perform_fortify
    PerformFortify.new(
      territory_from: @game.territories[@params[:from].to_i],
      territory_to: @game.territories[@params[:to].to_i],
      game_state: @game_state,
      fortifying_units: @params[:units].to_i
    )
  end

  def perform_reinforce
    PerformReinforce.new(
      game_state: @game_state,
      territory: @game.territories[@params[:to].to_i],
      units_to_reinforce: @params[:units].to_i
    )
  end

  def end_turn
    EndTurn.new(@game_state)
  end
end
