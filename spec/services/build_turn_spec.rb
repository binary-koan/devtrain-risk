require "rails_helper"

RSpec.describe BuildTurn do
  let(:game) { create(:game) }

  let(:jupiter) { create(:territory, game: game, name: "Jupiter") }
  let(:mars) { create(:territory, game: game, name: "Mars") }

  let(:player1) { create(:player, game: game, name: "Player 1") }
  let(:player2) { create(:player, game: game, name: "Player 2") }

  subject(:service) { BuildTurn.new(game.events) }

  before do
    create(:reinforce_event, territory: jupiter, player: player1)
    create(:reinforce_event, territory: mars, player: player2)
    create(:start_turn_event, player: player1)
  end

  describe "#call" do
    let(:pre_game_turn) { instance_double(Turn) }
    let(:first_turn) { instance_double(Turn) }

    before do
      expect(Turn).to receive(:new).with(game.events.first(2), nil).and_return pre_game_turn
    end

    context "when the game has just been started" do
      before do
        expect(Turn).to receive(:new).with(
          game.events.last(1), pre_game_turn
        ).and_return first_turn
      end

      it "creates and returns a turn for the first player" do
        expect(service.call).to eq first_turn
      end
    end

    context "when actions have been performed in the latest turn" do
      before do
        create(:reinforce_event, territory: jupiter, player: player1)
        create(:attack_event, player: player1, territory: mars, units_killed: 2)

        expect(Turn).to receive(:new).with(
          game.events.last(3), pre_game_turn
        ).and_return first_turn
      end

      it "returns a turn for the first player with all performed events" do
        expect(service.call).to eq first_turn
      end
    end

    context "when more than one turn exists" do
      let(:second_turn) { instance_double(Turn) }

      before do
        create(:reinforce_event, territory: jupiter, player: player1)
        create(:start_turn_event, player: player2)
        create(:reinforce_event, territory: mars, player: player2)

        expect(Turn).to receive(:new).with(
          game.events[2..3], pre_game_turn
        ).and_return first_turn

        expect(Turn).to receive(:new).with(
          game.events.last(2), first_turn
        ).and_return second_turn
      end

      it "returns a turn for the second player" do
        expect(service.call).to eq second_turn
      end
    end
  end
end
