class SubmitEvent
  attr_reader :errors

  def initialize(game, params)
    @game = game
    @turn = BuildTurn.new(@game.events).call
    @params = params
    @errors = []
  end

  def call
    service = service_for_event_type

    if service.nil?
      errors << :unknown_event_type
    elsif player_has_no_territories?
      errors << :no_territories
    elsif !service.call
      errors.concat(service.errors)
    end

    errors.none?
  end

  private

  def service_for_event_type
    case @params[:event][:event_type]
    when "attack" then perform_attack
    when "fortify" then perform_fortify
    when "reinforce" then perform_reinforce
    when "start_turn" then end_turn
    end
  end

  def player_has_no_territories?
    @turn.game_state.owned_territories(@turn.player).none?
  end

  def perform_attack
    PerformAttack.new(
      territory_from: @game.territories[@params[:from].to_i],
      territory_to: @game.territories[@params[:to].to_i],
      turn: @turn,
      attacking_units: @params[:units].to_i
    )
  end

  def perform_fortify
    PerformFortify.new(
      territory_from: @game.territories[@params[:from].to_i],
      territory_to: @game.territories[@params[:to].to_i],
      turn: @turn,
      fortifying_units: @params[:units].to_i
    )
  end

  def perform_reinforce
    PerformReinforce.new(
      turn: @turn,
      territory: @game.territories[@params[:to].to_i],
      units_to_reinforce: @params[:units].to_i
    )
  end

  def end_turn
    EndTurn.new(@turn)
  end
end
