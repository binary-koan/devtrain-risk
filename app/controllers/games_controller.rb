class GamesController < ApplicationController
  before_action :assign_game, except: [:new, :create]

  def new; end

  def create
    service = CreateGame.new(map_name: map_name, player_count: player_count)
    game = service.call

    if game.present? && service.errors.empty?
      redirect_to game
    else
      #TODO render new
      flash.alert = service.errors
      redirect_to :back
    end
  end

  def show
    @game_state = BuildGameState.new(@game.events).call
    @allowed_events = GetAllowedEvents.new(@game_state, @game.events).call
    #TODO not here
    @active_players = @game.players.select { |player| @game_state.in_game?(player) }

    respond_to do |format|
      format.html

      format.json do
        #TODO rails can do this
        render json: { content: render_to_string(partial: "games/game_display", formats: [:html]) }
      end
    end
  end

  private

  def map_name
    params.require(:map_name)
  end

  def player_count
    params.require(:player_count).to_i
  end

  def assign_game
    @game = Game.find(params[:id])
  end
end
