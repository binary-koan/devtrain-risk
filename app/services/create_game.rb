class CreateGame
  class Error < StandardError; end

  TERRITORY_COUNT = 6
  TERRITORY_EDGES = [[0,1],[0,2],[1,2],[2,4],[2,3],[4,5],[3,5]]
  INITIAL_UNITS = 10

  def initialize; end

  def call
    ActiveRecord::Base.transaction do
      create_game
      create_territories
      create_players
      assign_players_to_territories
      assign_units_to_players
    end
  #rescue ActiveRecord::ActiveRecordError => e
    #raise Error, e.message
  end

  def create_game
    @game = Game.create!
  end

  def create_territories
    TERRITORY_COUNT.times { @game.territories.create! }
    @territories = @game.territories
    TERRITORY_EDGES.each do |edge|
      TerritoryLink.create!(from_territory: @game.territories[edge[0]],
                            to_territory: @game.territories[edge[1]])
    end
  end

  def create_players
    @players = [@game.players.create!(name: "Player 1"), @game.players.create!(name: "Player 2")]
  end

  def assign_players_to_territories
    player_territories = @territories.shuffle.group_by.with_index do |_, index|
      @players[index % @players.size]
    end

    player_territories.each do |player, territories|
      event = player.events.create!(event_type: :reinforce)
      territories.each do |territory|
        event.actions.create!(territory: territory, territory_owner: player, units_difference: INITIAL_UNITS)
      end
    end
  end

  def assign_units_to_players

  end
end
