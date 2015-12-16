class CreateGame
  MIN_PLAYERS = 3
  MAX_PLAYERS = 6

  DEFAULT_MAP_NAME = "default"
  INITIAL_UNITS = 5

  attr_reader :errors

  def initialize(map_name: DEFAULT_MAP_NAME, player_count: MIN_PLAYERS)
    @map_name     = map_name
    @player_count = player_count
    @errors       = []
  end

  def call
    if (MIN_PLAYERS..MAX_PLAYERS).exclude?(@player_count)
      errors << :incorrect_player_count
    else
      create_game!
    end

    @game
  end

  private

  def invalid_map?(name)

  end

  def create_game!
    ActiveRecord::Base.transaction do
      @game = Game.create!
      @players = create_players!

      create_map!
      assign_players_to_territories!
      start_game!
    end
  end

  def create_players!
    @player_count.times.map do |i|
      @game.players.create!(name: "Player #{i + 1}")
    end
  end

  def create_map!
    service = CreateMap.new(game: @game, map_name: @map_name)

    unless service.call
      errors.concat(service.errors)
      raise ActiveRecord::Rollback
    end
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
