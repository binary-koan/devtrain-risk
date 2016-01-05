require "rails_helper"

RSpec.describe BuildGameState do
  let(:game) { create(:game) }
  let(:continent) { create(:continent) }

  let(:jupiter) { create(:territory, name: "Jupiter", continent: continent) }
  let(:mars) { create(:territory, name: "Mars", continent: continent) }

  let(:player1) { create(:player, game: game, name: "Player 1") }
  let(:player2) { create(:player, game: game, name: "Player 2") }

  subject(:service) { BuildGameState.new(game.events) }

  before do
    create(:reinforce_event, territory: jupiter, player: player1)
    create(:reinforce_event, territory: mars, player: player2)
    create(:start_turn_event, player: player1)
  end

  describe "#call" do
    context "when the game has just been started" do
      it "returns a game state with the correct territory setup" do
        state = service.call

        expect(state.territory_owner(jupiter)).to eq player1
        expect(state.territory_owner(mars)).to eq player2
      end
    end

    context "when actions have been performed in the latest turn" do
      before do
        create(:reinforce_event, territory: jupiter, player: player1)
        create(:attack_event, player: player1, territory: mars, units: 2)
      end

      it "returns a state with the events applied" do
        state = service.call

        expect(state.units_on_territory(jupiter)).to eq 6
        expect(state.territory_owner(mars)).to eq player1
      end
    end
  end
end
