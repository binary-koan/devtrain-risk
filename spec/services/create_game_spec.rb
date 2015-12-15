require "rails_helper"

RSpec.describe CreateGame do
  #TODO test with different numbers of players
  describe "#call" do
    let(:map_name) { "default" }
    let(:create_map) { instance_double(CreateMap) }

    let(:service) { CreateGame.new(map_name: map_name) }

    subject(:game) { service.call }
    let(:game_state) { GameState.new(game, game.events) }

    it "returns a saved game instance" do
      expect(game).to be_a Game
      expect(game).to be_persisted
    end

    it "creates players for the game" do
      expect(game.players.size).to eq 3
    end

    it "assigns names to the players" do
      expect(game.players[0].name).to eq "Player 1"
      expect(game.players[1].name).to eq "Player 2"
    end

    it "has errors with an invalid map name" do
      expect(CreateMap).to receive(:new).and_return create_map
      expect(create_map).to receive(:call).and_return false
      expect(create_map).to receive(:errors).and_return [:not_valid_map_name]
      service.call
    end

    #TODO
    # it "assigns all territories to players" do
    #   game.territories.each do |territory|
    #     expect(game.players).to include(territory.actions.first.territory_owner)
    #   end
    # end

    it "makes sure that each player owns the same number of territories" do
      player_territories = game.players.map { |player| game_state.owned_territories(player) }
      expect(player_territories.map(&:size).uniq.size).to eq 1
    end

    it "adds units to territories" do
      game.territories.each do |territory|
        expect(game_state.units_on_territory(territory)).to eq 5
      end
    end

    it "creates a start turn event for the initial player" do
      expect(game.events.last.event_type).to eq "start_turn"
      expect(game.events.last.player).to eq game.players.first
    end
  end
end
