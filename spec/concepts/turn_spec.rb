require "rails_helper"

RSpec.describe Turn do
  fixtures :games, :players, :territories

  let(:game) { games(:game) }
  let(:player) { players(:player1) }

  let(:turn) { Turn.new(game.events) }

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
          units_difference: 1
        )
      end

      it { is_expected.to eq true }
    end

    context "when an attack has been made" do
      before do
        create(
          :takeover_event,
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
          units_difference: 1
        )
      end

      pending "TODO test when fortified"

      it { is_expected.to eq false }
    end

    context "when an attack has been made" do
      before do
        create(
          :takeover_event,
          player: player,
          territory: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq true }
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
          :takeover_event,
          player: player,
          territory: territories(:territory_top_left)
        )
      end

      it { is_expected.to eq true }
    end
  end

  describe "#actions" do
    pending "TODO"
  end
end
