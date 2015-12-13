class GamesController < ApplicationController
  before_action :assign_game, except: [:new, :create]

  def new
  end

  def create
    service = CreateGame.new(map_name: map_name)
    game = service.call

    if game.present? && service.errors.empty?
      redirect_to game
    else
      flash.alert = service.errors
      redirect_to :back
    end
  end

  def show
    @turn = BuildTurn.new(@game.events).call

    respond_to do |format|
      format.html

      format.json do
        serializer = GameStateJson.new(@turn)
        render json: { state: serializer.json }
      end
    end
  end

  private

  def map_name
    params.require(:map_name)
  end

  def assign_game
    @game = Game.find(params[:id])
  end
end
