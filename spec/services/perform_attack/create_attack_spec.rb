require "rails_helper"

RSpec.describe PerformAttack::CreateAttack do
  def kill_on_territory(territory, player, count)
    create(
      :reinforce_event,
      player: player,
      territory: territory,
      units_difference: -count
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

    subject(:attack_event) { service.call }

    context "when attacking with one unit" do
      let(:attacking_units) { 1 }

      context "the attacker loses the dice roll" do
        before do
          expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[6, 1]] }
        end

        it "removes the one attacking unit" do
          expect(attack_event.actions[0].territory).to eq territory_from
          expect(attack_event.actions[0].units_difference).to eq -1
        end
      end

      context "the attacker wins the dice roll" do
        before do
          expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6]] }
        end

        it "removes the one defending unit" do
          expect(attack_event.actions[0].territory).to eq territory_to
          expect(attack_event.actions[0].units_difference).to eq -1
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
          expect(attack_event.actions[0].territory).to eq territory_from
          expect(attack_event.actions[0].units_difference).to be -2
        end
      end

      context "when the attacker wins both dice rolls" do
        before do
          expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6], [1, 6]] }
        end

        it "removes both of the defending units" do
          expect(attack_event.actions[0].territory).to eq territory_to
          expect(attack_event.actions[0].units_difference).to be -2
        end
      end

      context "when each player loses one die roll" do
        before do
          expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[6, 1], [1, 6]] }
        end

        it "removes one attacking unit and one defending unit" do
          expect(attack_event.actions[0].territory).to eq territory_to
          expect(attack_event.actions[0].units_difference).to be -1
          expect(attack_event.actions[1].territory).to eq territory_from
          expect(attack_event.actions[1].units_difference).to be -1
        end
      end
    end

    context "when the attackers' and defenders' rolls match" do
      before do
        expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[3, 3], [2, 2]] }
      end

      it "removes both attackers" do
        expect(attack_event.actions[0].units_difference).to eq -2
        expect(attack_event.actions[0].territory).to eq territory_from
      end

      it "doesn't change the ownership of the territory" do
        territory_owner = attack_event.actions[0].territory_owner
        expect(territory_owner).to eq players(:player1)
      end
    end

    context "when the defender has lost all their units" do
      before do
        kill_on_territory(territory_to, players(:player2), 4)

        expect(PerformAttack::RollDice).to receive(:new).and_return -> { [[1, 6]] }
      end

      let(:remove_defenders_event) { attack_event.actions[0] }
      let(:add_attackers_event) { attack_event.actions[1] }
      let(:remove_attackers_event) { attack_event.actions[2] }

      it "removes all defenders from defeated territory" do
        expect(remove_defenders_event.units_difference).to eq -1
        expect(remove_defenders_event.territory).to eq territories(:territory_bottom_left)
        expect(remove_defenders_event.territory_owner).to eq players(:player2)
      end

      it "adds attacking units to the defeated territory" do
        expect(add_attackers_event.units_difference).to eq 1
        expect(add_attackers_event.territory).to eq territories(:territory_bottom_left)
        expect(add_attackers_event.territory_owner).to eq players(:player1)
      end

      it "removes attackers from the attacking territory" do
        expect(remove_attackers_event.units_difference).to eq -1
        expect(remove_attackers_event.territory).to eq territories(:territory_top_left)
        expect(remove_attackers_event.territory_owner).to eq players(:player1)
      end
    end
  end
end
