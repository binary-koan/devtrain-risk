require "rails_helper"

RSpec.describe Turn do
  fixtures :games, :players, :territories, :events, :"action/adds"

  let(:game) { games(:game) }
  let(:player) { players(:player1) }

  let(:events) { game.events }
  let(:previous_turn) { nil }

  let(:turn) { Turn.new(events, previous_turn) }

  describe "#can_reinforce?" do
    let(:reinforcement_units) { 1 }

    subject { turn.can_reinforce?(reinforcement_units) }

    context "when a turn has just been started" do
      context "when trying to reinforce with a sensible number of units" do
        it { is_expected.to eq true }
      end

      context "when trying to reinforce with too many units" do
        let(:reinforcement_units) { 100 }

        it { is_expected.to eq false }
      end
    end

    context "when a complete reinforcement has already been made" do
      before do
        create(
          :reinforce_event,
          player: player,
          territory: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq false }
    end

    context "when an incomplete reinforcement has been made" do
      before do
        create(
          :reinforce_event,
          player: player,
          territory: territories(:territory_top_left),
          units: 1
        )
      end

      it { is_expected.to eq true }
    end

    context "when an attack has been made" do
      before do
        create(
          :attack_event,
          player: player,
          territory: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq false }
    end
  end

  describe "#can_attack?" do
    subject { turn.can_attack? }

    context "when a turn has just been started" do
      it { is_expected.to eq false }
    end

    context "when a complete reinforcement has been made" do
      before do
        create(
          :reinforce_event,
          player: player,
          territory: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq true }
    end

    context "when an incomplete reinforcement has been made" do
      before do
        create(
          :reinforce_event,
          player: player,
          territory: territories(:territory_top_left),
          units: 1
        )
      end

      it { is_expected.to eq false }
    end

    context "when an attack has been made" do
      before do
        create(
          :attack_event,
          player: player,
          territory: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq true }
    end

    context "when a fortify move has been made" do
      before do
        create(
          :fortify_event,
          player: player,
          territory_from: territories(:territory_top_right),
          territory_to: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq false }
    end
  end

  describe "#can_fortify?" do
    subject { turn.can_fortify? }

    context "when a turn has just been started" do
      it { is_expected.to eq false }
    end

    context "when a complete reinforcement has been made" do
      before do
        create(
          :reinforce_event,
          player: player,
          territory: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq true }
    end

    context "when an attack has been made" do
      before do
        create(
          :attack_event,
          player: player,
          territory: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq true }
    end

    context "when a fortify move has already been made" do
      before do
        create(
          :fortify_event,
          player: player,
          territory_from: territories(:territory_top_right),
          territory_to: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq false }
    end
  end

  describe "#game_state" do
    let(:game_state) { instance_double(GameState) }

    context "with a single turn" do
      let(:events) do
        [
          create(:attack_event, player: player, territory: territories(:territory_top_left)),
          create(:attack_event, player: player, territory: territories(:territory_top_right))
        ]
      end

      it "passes the turn's events to a new game state" do
        expect(GameState).to receive(:new).with(game, events).and_return(game_state)
        expect(turn.game_state).to eq game_state
      end
    end

    context "with multiple turns" do
      let(:all_events) do
        [
          create(:attack_event, player: player, territory: territories(:territory_top_left)),
          create(:attack_event, player: player, territory: territories(:territory_top_right)),
          create(:attack_event, player: player, territory: territories(:territory_bottom_left)),
          create(:attack_event, player: player, territory: territories(:territory_bottom_right))
        ]
      end

      let(:previous_turn) { Turn.new(all_events.first(2)) }
      let(:events) { all_events.last(2) }

      it "passes all events in order to the game state" do
        expect(GameState).to receive(:new).with(game, all_events).and_return(game_state)
        expect(turn.game_state).to eq game_state
      end
    end
  end
end
