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

  fixtures :games, :players, :territories, :territory_links, :events, :actions

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
          expect(attack_events[0].actions[0].territory).to eq territory_from
          expect(attack_events[0].actions[0].units_difference).to eq -1
        end
      end

      context "the attacker wins every die roll" do
        before do
          5.times { expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6]] } }
        end

        it "removes the one defending unit" do
          expect(attack_events[0].actions[0].territory).to eq territory_to
          expect(attack_events[0].actions[0].units_difference).to eq -1
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
          expect(attack_events[0].actions[0].territory).to eq territory_from
          expect(attack_events[0].actions[0].units_difference).to be -2
        end
      end

      context "when the attacker always wins both dice rolls" do
        before do
          3.times { expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6], [1, 6]] } }
        end

        it "removes both of the defending units" do
          expect(attack_events[0].actions[0].territory).to eq territory_to
          expect(attack_events[0].actions[0].units_difference).to be -2
        end
      end

      context "when each player loses one die roll" do
        before do
          2.times { expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[6, 1], [1, 6]] } }
        end

        it "removes one attacking unit and one defending unit" do
          expect(attack_events[0].actions[0].territory).to eq territory_to
          expect(attack_events[0].actions[0].units_difference).to be -1
          expect(attack_events[0].actions[1].territory).to eq territory_from
          expect(attack_events[0].actions[1].units_difference).to be -1
        end
      end
    end

    context "when the attackers' and defenders' rolls match" do
      before do
        2.times { expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[3, 3], [2, 2]] } }
      end

      it "removes both attackers" do
        expect(attack_events[0].actions[0].units_difference).to eq -2
        expect(attack_events[0].actions[0].territory).to eq territory_from
      end

      it "doesn't change the ownership of the territory" do
        territory_owner = attack_events[0].actions[0].territory_owner
        expect(territory_owner).to eq players(:player1)
      end
    end

    context "when the defender has lost all their units" do
      before do
        kill_on_territory(territory_to, players(:player2), 4)

        expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6]] }
      end

      let(:remove_defenders_event) { attack_events[0].actions[0] }
      let(:add_attackers_event) { attack_events[0].actions[1] }
      let(:remove_attackers_event) { attack_events[0].actions[2] }

      it "removes all defenders from defeated territory" do
        expect(remove_defenders_event.units_difference).to eq -1
        expect(remove_defenders_event.territory).to eq territories(:territory_bottom_left)
        expect(remove_defenders_event.territory_owner).to eq players(:player2)
      end

      it "adds attacking units to the defeated territory" do
        expect(add_attackers_event.units_difference).to eq 3
        expect(add_attackers_event.territory).to eq territories(:territory_bottom_left)
        expect(add_attackers_event.territory_owner).to eq players(:player1)
      end

      it "removes attackers from the attacking territory" do
        expect(remove_attackers_event.units_difference).to eq -3
        expect(remove_attackers_event.territory).to eq territories(:territory_top_left)
        expect(remove_attackers_event.territory_owner).to eq players(:player1)
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
      let(:third_event) { attack_events[2] }

      it "kills 2 defenders in the first event" do
        expect(first_event.actions.length).to eq 1
        action = first_event.actions[0]
        expect(action.action_type).to eq "kill"
        expect(action.territory).to be territory_to
        expect(action.territory_owner).to eq players(:player2)
        expect(action.units_difference).to be -2
      end

      it "kills 2 defenders in the second event" do
        expect(second_event.actions.length).to eq 1
        action = second_event.actions[0]
        expect(action.action_type).to eq "kill"
        expect(action.territory).to be territory_to
        expect(action.territory_owner).to eq players(:player2)
        expect(action.units_difference).to be -2
      end

      context "killing the last defend and takes over the territory" do
        it "contains the correct number of action" do
          expect(third_event.actions.length).to eq 3
        end

        let(:kill_action) { third_event.actions[0] }
        let(:move_to_action) { third_event.actions[1] }
        let(:move_from_action) { third_event.actions[2] }

        it "kills the last defender" do
          expect(kill_action.action_type).to eq "kill"
          expect(kill_action.territory).to be territory_to
          expect(kill_action.territory_owner).to eq players(:player2)
          expect(kill_action.units_difference).to be -1
        end

        it "moves the attackers to the territory" do
          expect(move_to_action.action_type).to eq "move_to"
          expect(move_to_action.territory).to be territory_to
          expect(move_to_action.territory_owner).to eq players(:player1)
          expect(move_to_action.units_difference).to be 4
        end

        it "removes the attackers from the attacking territory" do
          expect(move_from_action.action_type).to eq "move_from"
          expect(move_from_action.territory).to be territory_from
          expect(move_from_action.territory_owner).to eq players(:player1)
          expect(move_from_action.units_difference).to be -4
        end
      end
    end
  end
end
