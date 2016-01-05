class SubmitEvent
  attr_reader :errors, :service

  def initialize(game, dice_roller, params)
    @game = game
    @dice_roller = dice_roller
    @turn = BuildTurn.new(@game.events).call
    @params = params
    @errors = []
  end

  def call
    @service = service_for_event_type

    if service.nil?
      errors << :unknown_event_type
    elsif @turn.game_state.won?
      errors << :game_finished
    elsif !service.call
      errors.concat(service.errors)
    end

    errors.none?
  end

  private

  def service_for_event_type
    case event_params[:event_type]
    when "attack" then perform_attack
    when "fortify" then perform_fortify
    when "reinforce" then perform_reinforce
    when "start_turn" then start_next_turn
    end
  end

  def perform_attack
    PerformAttack.new(
      territory_from: @game.territories.find_by(name: @params[:from]),
      territory_to: @game.territories.find_by(name: @params[:to]),
      turn: @turn,
      attacking_units: @params[:units].to_i,
      dice_roller: @dice_roller
    )
  end

  def perform_fortify
    PerformFortify.new(
      territory_from: @game.territories.find_by(name: @params[:from]),
      territory_to: @game.territories.find_by(name: @params[:to]),
      turn: @turn,
      fortifying_units: @params[:units].to_i
    )
  end

  def perform_reinforce
    PerformReinforce.new(
      turn: @turn,
      territory: @game.territories.find_by(name: @params[:to]),
      units_to_reinforce: @params[:units].to_i
    )
  end

  def start_next_turn
    StartNextTurn.new(@turn)
  end

  def event_params
    #TODO controller level
    @params.require(:event).permit(:event_type)
  end
end
