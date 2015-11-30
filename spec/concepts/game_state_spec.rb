require "rails_helper"

RSpec.describe GameState do
  let(:game) { CreateGame.new.call }
  subject(:game_state) { GameState.new(game) }

  describe "#current_player" do
    subject { game_state.current_player }

    context "at the start of the game" do
      it { is_expected.to eq game.players.first }
    end

    context "when player 1 has ended their turn" do
      before { EndTurn.new(game).call }

      it { is_expected.to eq game.players[1] }
    end

    context "when both players have ended their turns" do
      before { 2.times { EndTurn.new(game).call } }

      it { is_expected.to eq game.players.first }
    end
  end

  describe "#owned_territories" do
    context "at the start of the game" do
      it "is the same number for both players" do
        player1_territories = game_state.owned_territories(game.players.first)
        player2_territories = game_state.owned_territories(game.players.last)

        expect(player1_territories.size).to eq player2_territories.size
      end
    end
  end

  describe "#territory_owner" do
    it "is the inverse of #owned_territories" do
      player = game.players.first
      owned_territories = game_state.owned_territories(player)
      expect(owned_territories).to be_all { |t| game_state.territory_owner(t) == player }
    end
  end
end
