require "rails_helper"

RSpec.describe PerformReinforce do
  def start_turn(player)
    create(:start_turn_event, player: player, )
  end

  let(:game) { create(:game) }
  let(:continent) { create(:continent) }

  let!(:player1) { create(:player, name: "Player 1", game: game) }
  let!(:player2) { create(:player, name: "Player 2", game: game) }
  let!(:jupiter) { create(:territory, continent: continent) }
  let!(:mars)    { create(:territory, continent: continent) }

  let(:game_state) { BuildGameState.new(game.events).call }

  let(:units_to_reinforce) { 3 }

  let(:service) do
    PerformReinforce.new(
      game_state:         game_state,
      territory:          territory,
      units_to_reinforce: units_to_reinforce
    )
  end

  let(:reinforce_event) { service.reinforce_event }
  let(:reinforce_action) { reinforce_event.action }

  describe "#call" do
    let(:territory) { mars }

    before do
      create(:reinforce_event, player: player1, territory: mars)
      create(:reinforce_event, player: player2, territory: jupiter)
      start_turn(player1)
    end

    context "with a territory owned" do
      let!(:result) { service.call }

      it "succeeds" do
        expect(result).to eq true
      end

      it "adds units to the territory" do
        expect(reinforce_action.units).to eq 3
      end

      it "keeps the correct territory owner" do
        expect(reinforce_event.player).to eq player1
      end
    end

    context "when player 1 has ended their turn" do
      let(:player) { player2 }
      let(:territory) { jupiter }

      before { start_turn(player2) }

      let!(:result) { service.call }

      it "succeeds" do
        expect(result).to eq true
      end

      it "adds units to the territory" do
        expect(reinforce_action.units).to eq 3
      end

      it "keeps the correct territory owner" do
        expect(reinforce_event.player).to eq player2
      end
    end

    context "player1 reinforces a single unit" do
      let(:units_to_reinforce) { 1 }
      let(:reinforce_event) { service.reinforce_event }

      let!(:result) { service.call }

      it "succeeds" do
        expect(result).to eq true
      end

      it "adds units to the territory" do
        expect(reinforce_action.units).to eq 1
      end

      it "keeps the correct territory owner" do
        expect(reinforce_event.player).to eq player1
      end
    end

    context "when trying to reinforce an enemy territory" do
      let(:territory) { jupiter }

      it "fails with an error" do
        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :reinforcing_enemy_territory
      end
    end

    context "when trying to reinforce with too many units" do
      let(:units_to_reinforce) { 100 }

      it "fails with an error" do
        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :cannot_reinforce
      end
    end

    context "when trying to reinforce with too few units" do
      let(:units_to_reinforce) { 0 }

      it "fails with an error" do
        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :too_few_reinforcing_units
      end
    end
  end
end
