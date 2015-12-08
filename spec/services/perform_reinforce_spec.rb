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

  let(:turn) { BuildTurn.new(game.events).call }
  let(:game_state) { turn.game_state }
  let(:reinforcements) { turn.reinforcements }

  let(:units_to_reinforce) { 3 }

  let(:territory) { jupiter }

  let(:service) do
    PerformReinforce.new(
      turn:               turn,
      territory:          territory,
      units_to_reinforce: units_to_reinforce
    )
  end

  describe "#call" do
    context "with a territory owned" do
      let(:reinforce_event) { service.reinforce_event }
      let(:territory) { mars }

      before do
        create(:reinforce_event, player: player1, game: game, territory: mars)
        create(:reinforce_event, player: player2, game: game, territory: jupiter)
        start_turn(player1)
        service.call
      end

      it "adds units to the territory" do
        expect(reinforce_event.actions[0].units_difference).to eq reinforcements.remaining_units
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
        expect(reinforce_event.actions[0].units_difference).to eq reinforcements.remaining_units
      end

      it "adds units to the player's territory" do
        expect(reinforce_event.actions[0].territory_owner).to eq player2
      end
    end

    context "player1 reinforces a single unit" do
      let(:units_to_reinforce) { 1 }
      let(:territory) { mars }

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

    context "player 1 tries to reinforce an enemy territory" do
      let(:territory) { jupiter }

      before do
        create(:reinforce_event, player: player1, game: game, territory: mars)
        create(:reinforce_event, player: player2, game: game, territory: jupiter)
        start_turn(player1)
        service.call
      end

      it "returns a reinforcing_enemy_territory error" do
        expect(service.errors).to contain_exactly :reinforcing_enemy_territory
      end
    end

    pending "TODO try reinforcing with too many units"
  end
end
