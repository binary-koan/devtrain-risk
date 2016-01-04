require "rails_helper"

RSpec.describe PerformAttack::ValidateAttack do
  def kill_on_territory(territory, player, count)
    create(
      :attack_event,
      player: player,
      territory: territory,
      units: count
    )
  end

  fixtures :games, :players, :territories, :territory_links, :events

  let(:game) { games(:game) }

  let(:turn) { BuildTurn.new(game.events).call }

  let(:attacking_units) { 3 }
  let(:dice_roller) { DiceRoller.new }

  let(:service) do
    PerformAttack::ValidateAttack.new(
      territory_from:  territory_from,
      territory_to:    territory_to,
      turn:            turn,
      attacking_units: attacking_units,
      dice_roller:     dice_roller
    )
  end

  before do
    create(
      :reinforce_event,
      player: players(:player1),
      territory: territories(:territory_top_left),
      units: 4
    )
  end

  describe "#call" do
    context "attacking from territory that is not current players" do
      let(:territory_from) { territories(:territory_bottom_left) }
      let(:territory_to) { territories(:territory_top_left) }

      it "returns a wrong player error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :wrong_player
      end
    end

    context "when attacking the same territory" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_left) }

      it "returns a no link error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :no_link
      end
    end

    context "when attacking your own territory" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_right) }

      it "indicates that it is not a valid move" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :own_territory
      end
    end

    context "when the territory isn't a neighbour" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_bottom_right) }

      it "returns a no link error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :no_link
      end
    end

    context "when the territory is a neighbour" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_bottom_left) }

      context "when the turn state disallows attacking" do
        it "returns a wrong phase error" do
          expect(turn).to receive(:can_attack?).and_return false
          expect(service.call).to eq false
          expect(service.errors).to contain_exactly :wrong_phase
        end
      end

      context "when the attacker only has one unit left" do
        let(:territory_from) { territories(:territory_top_left) }
        let(:territory_to) { territories(:territory_bottom_left) }

        before do
          kill_on_territory(territory_from, players(:player1), 8)
        end

        it "returns a cannot attack with one unit error" do
          expect(service.call).to be false
          expect(service.errors).to contain_exactly :too_few_available_attackers
        end
      end

      context "when trying to attack with more than the remaining number of units" do
        let(:territory_from) { territories(:territory_top_left) }
        let(:territory_to) { territories(:territory_bottom_left) }

        let(:attacking_units) { 3 }

        before do
          kill_on_territory(territory_from, players(:player1), 6)
        end

        it "fails with an error" do
          expect(service.call).to be false
          expect(service.errors).to contain_exactly :too_many_units
        end
      end

      context "when the attacker tries to attack with no units" do
        let(:attacking_units) { 0 }

        it "returns a too_few_units error" do
          expect(service.call).to be false
          expect(service.errors).to contain_exactly :too_few_units
        end
      end

      context "when all conditions are satisfied" do
        it "returns true and has no errors" do
          expect(service.call).to eq true
          expect(service.errors).to be_empty
        end
      end
    end
  end
end
