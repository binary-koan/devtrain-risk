require "rails_helper"

RSpec.describe Turn do
  def create_complete_reinforcement
    create(:reinforce_event, player: player, territory: territories(:territory_top_left))
  end

  def create_incomplete_reinforcement
    create(:reinforce_event, player: player, territory: territories(:territory_top_left), units: 1)
  end

  def create_attack(
      territory_from: territories(:territory_top_right),
      territory_to: territories(:territory_top_left),
      units: 2)
    create(:attack_event, player: player, territory_from: territory_from, territory: territory_to, units: units)
  end

  def create_fortification
    create(:fortify_event,
      player: player,
      territory_from: territories(:territory_top_right),
      territory_to: territories(:territory_top_left)
    )
  end

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
      before { create_complete_reinforcement }

      it { is_expected.to eq false }
    end

    context "when an incomplete reinforcement has been made" do
      before { create_incomplete_reinforcement }

      it { is_expected.to eq true }
    end

    context "when an attack has been made" do
      before { create_attack }

      it { is_expected.to eq false }
    end
  end

  describe "#can_attack?" do
    subject { turn.can_attack? }

    context "when a turn has just been started" do
      it { is_expected.to eq false }
    end

    context "when a complete reinforcement has been made" do
      before { create_complete_reinforcement }

      it { is_expected.to eq true }
    end

    context "when an incomplete reinforcement has been made" do
      before { create_incomplete_reinforcement }

      it { is_expected.to eq false }
    end

    context "when an attack has been made" do
      before { create_attack }

      it { is_expected.to eq true }
    end

    context "when a fortify move has been made" do
      before { create_fortification }

      it { is_expected.to eq false }
    end
  end

  describe "#can_fortify?" do
    subject { turn.can_fortify?(territories(:territory_top_left), territories(:territory_top_right)) }

    context "when a turn has just been started" do
      it { is_expected.to eq false }
    end

    context "when a complete reinforcement has been made" do
      before { create_complete_reinforcement }

      it { is_expected.to eq true }

      context "when an attack has been made" do
        before { create_attack }

        it { is_expected.to eq true }
      end

      context "when a fortify move has already been made" do
        before { create_fortification }

        it { is_expected.to eq false }
      end

      #TODO what do these mean/test?
      context "with an invalid attempt to reinforce after a takeover" do
        before do
          create_attack(
            territory_from: territories(:territory_top_right),
            territory_to: territories(:territory_bottom_left),
            units: 5
          )
        end

        it { is_expected.to eq false }
      end

      context "with a valid attempt to reinforce after a takeover" do
        before do
          create_attack(
            territory_from: territories(:territory_top_left),
            territory_to: territories(:territory_top_right),
            units: 8
          )
        end

        it { is_expected.to eq true }
      end
    end
  end

  describe "#can_end_turn?" do
    subject { turn.can_end_turn? }

    context "when a turn has just been started" do
      it { is_expected.to eq false }
    end

    context "when a complete reinforcement has been made" do
      before { create_complete_reinforcement }

      it { is_expected.to eq true }
    end

    context "when an attack has been made" do
      before { create_attack }

      it { is_expected.to eq true }
    end

    context "when a fortify move has been made" do
      before { create_fortification }

      it { is_expected.to eq true }
    end
  end

  describe "#allowed_events" do
    subject(:allowed_events) { turn.allowed_events }

    context "when a turn has just been started" do
      it "only allows a reinforce event" do
        expect(allowed_events.size).to eq 1
        expect(allowed_events.first.event_type).to eq "reinforce"
      end
    end

    context "when a complete reinforcement has been made" do
      before { create_complete_reinforcement }

      it "allows attack, fortify and end turn events" do
        expect(allowed_events).to be_one { |e| e.event_type == "attack" }
        expect(allowed_events).to be_one { |e| e.event_type == "fortify" }
        expect(allowed_events).to be_one { |e| e.event_type == "start_turn" }
      end
    end

    context "when an attack has been made" do
      before { create_attack }

      it "allows attack, fortify and end turn events" do
        expect(allowed_events).to be_one { |e| e.event_type == "attack" }
        expect(allowed_events).to be_one { |e| e.event_type == "fortify" }
        expect(allowed_events).to be_one { |e| e.event_type == "start_turn" }
      end
    end

    context "when a fortify move has been made" do
      before { create_fortification }

      it "only allows an end turn event" do
        expect(allowed_events.size).to eq 1
        expect(allowed_events.first.event_type).to eq "start_turn"
      end
    end

    context "when a fortify move has been made after an attack" do
      before do
        create_attack
        create_fortification
      end

      it "allows attack, fortify and end turn events" do
        expect(allowed_events).to be_one { |e| e.event_type == "attack" }
        expect(allowed_events).to be_one { |e| e.event_type == "fortify" }
        expect(allowed_events).to be_one { |e| e.event_type == "start_turn" }
      end
    end

    context "when a territory has been taken over" do
      before do
        create_attack(
          territory_from: territories(:territory_top_left),
          territory_to: territories(:territory_top_right),
          units: 5
        )
      end

      it "only allows a fortify event" do
        expect(allowed_events.size).to eq 1
        expect(allowed_events.first.event_type).to eq "fortify"
      end

      it "requires the event to be from and to the right territory" do
        action = allowed_events.first.action
        expect(action.territory_from).to eq territories(:territory_top_left)
        expect(action.territory_to).to eq territories(:territory_top_right)
      end
    end
  end

  describe "#game_state" do
    let(:game_state) { instance_double(GameState, owned_territories: []) }

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
        expect(GameState).to receive(:new).with(game, all_events.first(2)).and_return(game_state)
        expect(GameState).to receive(:new).with(game, all_events).and_return(game_state)
        expect(turn.game_state).to eq game_state
      end
    end
  end
end
