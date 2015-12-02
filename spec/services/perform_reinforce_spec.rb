require "rails_helper"
require_relative "../../app/concepts/game_state"
require_relative "../../app/services/perform_reinforce"


RSpec.describe PerformReinforce do
  let(:game)    { create(:game) }
  let(:player1) { create(:player, game: game) }
  let(:player2) { create(:player, game: game) }
  let(:jupiter) { create(:territory, game: game) }
  let(:mars)    { create(:territory, game: game) }

  let(:game_state) { GameState.new(game) }

  let(:service) do
    PerformReinforce.new(
      game_state: game_state,
      current_player: player
    )
  end

  describe "#call" do
    context "with no territories owned" do
      let(:player) { player1 }

      before(:each) { service.call }

      it "returns a no territory error for player 1" do
        expect(service.errors).to contain_exactly :no_territories
      end

      let(:player) { player2 }

      it "returns a no territory error for player 2" do
        expect(service.errors).to contain_exactly :no_territories
      end
    end

    context "with a territory owned" do
      before do
        create(:reinforce_event, player: player1, game: game, territory: mars)
        create(:reinforce_event, player: player2, game: game, territory: jupiter)
      end

      let(:player) { player1 }
      let(:reinforce_event) { service.call }
      let(:action) { reinforce_event.actions[0] }
      let(:reinforcement) { Reinforcement.new }

      it "adds units to the territory" do
        expect(action.units_difference).to be reinforcement.all_units
      end

      it "adds units to the player's territory" do
        expect(action.territory_owner).to be player1
      end

      context "player1 ends their turn" do
        let(:player) { player2 }
        let(:reinforce_event) { service.call }
        let(:action) { reinforce_event.actions[0] }

        it "adds units to the territory" do
          expect(action.units_difference).to be reinforcement.all_units
        end

        it "adds units to the player's territory" do
          expect(action.territory_owner).to be player2
        end
      end
    end
  end
end
