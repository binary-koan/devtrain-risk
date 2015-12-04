require "rails_helper"

RSpec.describe PerformReinforce do
  def start_turn(player)
    create(:start_turn_event, player: player, game: game)
  end

  let(:game) { create(:game) }

  let!(:player1) { create(:player, name: "Player 1", game: game) }
  let!(:player2) { create(:player, name: "Player 2", game: game) }
  let!(:jupiter) { create(:territory, game: game) }
  let!(:mars)    { create(:territory, game: game) }

  let(:game_state) { BuildGameState.new(game, game.events).call }
  let(:reinforcements) { Reinforcement.new(player1) }
  let(:units_to_reinforce) { 3 }

  let(:territory) { jupiter }

  let(:service) do
    PerformReinforce.new(
      game_state:         game_state,
      territory:          territory,
      units_to_reinforce: units_to_reinforce
    )
  end

  describe "#call" do
    context "with no territories owned" do
      before do
        start_turn(player1)
        service.call
      end

      it "returns a no territory error for player 1" do
        expect(service.errors).to contain_exactly :no_territories
      end

      let(:player) { player2 }

      it "returns a no territory error for player 2" do
        expect(service.errors).to contain_exactly :no_territories
      end
    end

    context "with a territory owned" do
      let(:reinforce_event) { service.reinforce_event }

      before do
        create(:reinforce_event, player: player1, game: game, territory: mars)
        create(:reinforce_event, player: player2, game: game, territory: jupiter)
        start_turn(player1)
        service.call
      end

      it "adds units to the territory" do
        expect(reinforce_event.actions[0].units_difference).to eq reinforcements.remaining_reinforcements
      end

      it "adds units to the player's territory" do
        expect(reinforce_event.actions[0].territory_owner).to eq player1
      end
    end

    context "player1 ends their turn" do
      let(:player) { player2 }
      let(:reinforce_event) { service.reinforce_event }

      before do
        create(:reinforce_event, player: player1, game: game, territory: mars)
        create(:reinforce_event, player: player2, game: game, territory: jupiter)
        start_turn(player1)
        start_turn(player2)
        service.call
      end

      it "adds units to the territory" do
        expect(reinforce_event.actions[0].units_difference).to eq reinforcements.remaining_reinforcements
      end

      it "adds units to the player's territory" do
        expect(reinforce_event.actions[0].territory_owner).to eq player2
      end
    end

    context "player1 reinforces a single unit" do
      let(:units_to_reinforce) { 1 }

      before do
        create(:reinforce_event, player: player1, game: game, territory: mars)
        create(:reinforce_event, player: player2, game: game, territory: jupiter)
        start_turn(player1)
        service.call
      end

      let(:reinforce_event) { service.reinforce_event }

      it "adds units to the territory" do
        expect(reinforce_event.actions[0].units_difference).to eq 1
      end

      it "adds units to the player's territory" do
        expect(reinforce_event.actions[0].territory_owner).to eq player1
      end
    end
  end
end
