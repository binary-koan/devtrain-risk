class SubmitEvent
  attr_reader :errors

  EVENT_TYPE_SERVICES = {
    "attack" => :perform_attack,
    "fortify" => :perform_fortify,
    "reinforce" => :perform_reinforce,
    "start_turn" => :end_turn
  }

  def initialize(game, params)
    @game = game
    @turn = BuildTurn.new(@game.events).call
    @params = params
    @errors = []
  end

  def call
    service = service_for_event_type

    if !service #TODO .nil?
      errors << :unknown_event_type
    elsif player_has_no_territories?
      errors << :no_territories
    elsif !service.call
      #TODO concat not +=
      @errors += service.errors
      return false #TODO remove
    end

    errors.none?
  end

  private

  #TODO change to case statement
  def service_for_event_type
    event_type = @params[:event][:event_type]

    send(EVENT_TYPE_SERVICES[event_type]) if EVENT_TYPE_SERVICES.has_key?(event_type)
  end

  def player_has_no_territories?
    @turn.game_state.owned_territories(@turn.player).length == 0#TODO empty?|none?
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
