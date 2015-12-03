require "rails_helper"

RSpec.describe CreateGame do
  describe "#call" do
    let(:service) { CreateGame.new }

    subject(:game) { service.call }
    let(:game_state) { GameState.current(game) }

    it "returns a saved game instance" do
      expect(game).to be_a Game
      expect(game).to be_persisted
    end

    it "creates players for the game" do
      expect(game.players.size).to eq 2
    end

    it "assigns names to the players" do
      expect(game.players[0].name).to eq "Player 1"
      expect(game.players[1].name).to eq "Player 2"
    end

    it "creates territories in the game" do
      expect(game.territories.size).to eq 6
    end

    it "assigns all territories to players" do
      # ^ is actually what the next line means (with this game structure), but it isn't exactly clear ...
      expect(game.territories).to be_all { |territory| territory.actions.size > 0 }
    end

    context "makes sure that each player owns the same number of territories" do
      pending "how should this work?"
    end

    it "adds units to territories" do
      game.territories.each do |territory|
        expect(game_state.units_on_territory(territory)).to eq 10
      end
    end

    it "creates a start turn event for the initial player" do
      expect(game.events.last.event_type).to eq "start_turn"
      expect(game_state.current_player).to eq game.players.first
    end
  end
end
