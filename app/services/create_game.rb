class CreateGame
  class Error < StandardError; end

  DEFAULT_MAP_NAME = "default"
  INITIAL_UNITS = 10

  attr_reader :errors

  def initialize(map_name: nil)
    @map_name = map_name || DEFAULT_MAP_NAME
    @errors   = []
  end

  def call
    ActiveRecord::Base.transaction do
      create_game!
      create_map!
      create_players!
      assign_players_to_territories!
      start_game!
    end

    @game
  end

  private

  def create_game!
    @game = Game.create!
  end

  def create_map!
    service = CreateMap.new(game: @game, map_name: @map_name)
    result = service.call

    if result.empty?
      @errors += service.errors
    else
      result
    end
  end

  def create_players!
    @players = [@game.players.create!(name: "Player 1"), @game.players.create!(name: "Player 2")]
  end

  def assign_players_to_territories!
    territories_by_player.each do |player, territories|
      populate_territories!(territories, player)
    end
  end

  def populate_territories!(territories, player)
    territories.each do |territory|
      event = player.events.reinforce.new
      event.action = Action::Add.create!(territory: territory, units: INITIAL_UNITS)
      event.save!
    end
  end

  def start_game!
    @game.players.first.events.start_turn.create!
  end

  def territories_by_player
    @game.territories.shuffle.group_by.with_index do |_, index|
      @players[index % @players.size]
    end
  end
end
