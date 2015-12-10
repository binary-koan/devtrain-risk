require "rails_helper"

RSpec.describe PerformAttack::CreateAttack do
  def kill_on_territory(territory, player, count)
    create(
      :attack_event,
      player: player,
      territory: territory,
      units_killed: count
    )
  end

  fixtures :games, :players, :territories, :territory_links, :events

  let(:game) { games(:game) }

  let(:turn) { BuildTurn.new(game.events).call }

  let(:attacking_units) { 3 }

  let(:service) do
    PerformAttack::CreateAttack.new(
      territory_from:  territory_from,
      territory_to:    territory_to,
      turn:            turn,
      attacking_units: attacking_units
    )
  end

  describe "#call" do
    let(:territory_from) { territories(:territory_top_left) }
    let(:territory_to) { territories(:territory_bottom_left) }

    subject(:attack_events) { service.call }

    context "when attacking with one unit" do
      let(:attacking_units) { 1 }

      context "the attacker loses the dice roll" do
        before do
          expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[6, 1]] }
        end

        it "removes the one attacking unit" do
          expect(attack_events[0].action).to be_a Action::Kill
          expect(attack_events[0].action.territory).to eq territory_from
          expect(attack_events[0].action.units).to eq 1
        end
      end

      context "the attacker wins every die roll" do
        before do
          5.times { expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6]] } }
        end

        it "removes the one defending unit" do
          expect(attack_events[0].action).to be_a Action::Kill
          expect(attack_events[0].action.territory).to eq territory_to
          expect(attack_events[0].action.units).to eq 1
        end
      end
    end

    context "when attacking with two units" do
      let(:attacking_units) { 2 }

      context "when the attacker loses both dice rolls" do
        before do
          expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[6, 1], [6, 1]] }
        end

        it "removes both of the attacking units" do
          expect(attack_events[0].action).to be_a Action::Kill
          expect(attack_events[0].action.territory).to eq territory_from
          expect(attack_events[0].action.units).to eq 2
        end
      end

      context "when each player loses one die roll" do
        before do
          2.times { expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[6, 1], [1, 6]] } }
        end

        it "removes one attacking unit and one defending unit" do
          expect(attack_events[0].action.territory).to eq territory_to
          expect(attack_events[0].action.units).to be 1
          expect(attack_events[1].action.territory).to eq territory_from
          expect(attack_events[1].action.units).to be 1
        end
      end
    end

    context "when the attackers' and defenders' rolls match" do
      before do
        2.times { expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[3, 3], [2, 2]] } }
      end

      it "removes both attackers" do
        expect(attack_events[0].action.units).to eq 2
        expect(attack_events[0].action.territory).to eq territory_from
      end

      it "doesn't change the ownership of the territory" do
        expect(attack_events[0].player).to eq players(:player1)
      end
    end

    context "when the defender has lost all their units" do
      before do
        kill_on_territory(territory_to, players(:player2), 4)

        expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6]] }
      end

      let(:remove_defenders_event) { attack_events[0] }
      let(:move_attackers_event) { attack_events[1] }

      it "removes all defenders from defeated territory" do
        expect(remove_defenders_event.action.units).to eq 1
        expect(remove_defenders_event.action.territory).to eq territory_to
        expect(remove_defenders_event.player).to eq players(:player2)
      end

      it "adds attacking units to the defeated territory" do
        expect(move_attackers_event.action.units).to eq 3
        expect(move_attackers_event.action.territory_from).to eq territory_from
        expect(move_attackers_event.action.territory_to).to eq territory_to
        expect(move_attackers_event.player).to eq players(:player1)
      end
    end

    context "when performing multiple attacks at once" do
      let(:attacking_units) { 4 }

      before do
        expect(PerformAttack::RollDice).to receive(:new).exactly(:twice).and_return -> { [[1, 6], [1, 6]] }
        expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6]] }
      end

      let(:first_event) { attack_events[0] }
      let(:second_event) { attack_events[1] }

      it "kills 2 defenders in the first event" do
        expect(first_event.action.territory).to eq territory_to
        expect(first_event.player).to eq players(:player2)
        expect(first_event.action.units).to be 2
      end

      it "kills 2 defenders in the second event" do
        expect(second_event.action.territory).to be territory_to
        expect(second_event.player).to eq players(:player2)
        expect(second_event.action.units).to be 2
      end

      context "killing the last defend and takes over the territory" do
        it "contains the correct number of actions" do
          expect(attack_events.length).to eq 4
        end

        let(:kill_event) { attack_events[2] }
        let(:move_event) { attack_events[3] }

        it "kills the last defender" do
          expect(kill_event.action.territory).to be territory_to
          expect(kill_event.player).to eq players(:player2)
          expect(kill_event.action.units).to be 1
        end

        it "moves the attackers to the territory" do
          expect(move_event.action.territory_from).to eq territory_from
          expect(move_event.action.territory_to).to eq territory_to
          expect(move_event.player).to eq players(:player1)
          expect(move_event.action.units).to eq 4
        end
      end
    end
  end
end
