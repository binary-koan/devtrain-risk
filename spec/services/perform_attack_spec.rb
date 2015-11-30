require "rails_helper"
require_relative "../../app/concepts/game_state"
require_relative "../../app/services/perform_attack"


RSpec.describe PerformAttack do

  def create_attack(territory_from, territory_to)
    PerformAttack.new(
      territory_from: territories(territory_from),
      territory_to:   territories(territory_to),
      game_state:     game_state
    )
  end

  describe "#call" do
    fixtures :games, :players, :territories, :territory_links, :events, :actions
    let(:game_state) { GameState.new(games(:game)) }

    context "attacking and defending the same territory" do
      let(:service) { create_attack(:territory_top_left, :territory_top_left) }
      let(:result) { service.call }

      it "indicates that it is not a valid move" do
        expect(result).to be nil
      end

      before { service.call }

      it "returns a no link error" do
        expect(service.errors[0]).to be :no_link
      end
    end

    context "attacking players own territory" do
      let(:service) { create_attack(:territory_top_left, :territory_top_right) }
      let(:result) { service.call }

      it "indicates that it is not a valid move" do
        expect(result).to be nil
      end

      before { service.call }

      it "returns an own territory error" do
        expect(service.errors[0]).to be :own_territory
      end
    end

    context "attacking an enemie's territory" do
      context "when the territory isn't a neighbour" do
        let(:service) { create_attack(:territory_top_left, :territory_bottom_right) }

        subject { service.call }

        it { is_expected.to be nil }

        before { service.call }

        it "returns a no link error" do
          expect(service.errors[0]).to be :no_link
        end
      end

      context "the territory is a neighbour" do
        let(:service) { create_attack(:territory_top_left, :territory_bottom_left) }
        subject { service.call }

        it { is_expected.to_not be nil }

        it "has no errors" do
          service.call
          expect(service.errors).to be_none
        end

        context "the attackers and defenders rolls match" do
          before do
            allow(service).to receive(:rand).and_return 6
          end

          it "removes 2 attackers" do
            action = service.call.actions[0]
            units_lost = action.units_difference

            expect(units_lost).to eq -2
          end
        end

        context "the attacker only has one unit left" do
          before do
            allow(service).to receive(:rand).and_return 6
            2.times { service.call }
          end

          subject { service.call }

          it { is_expected.to be nil }

          before { service.call }

          it "returns a cannot attack with one unit error" do
            expect(service.errors[0]).to be :cannot_attack_with_one_unit
          end
        end

        context "the defender loses units" do
          before do
            expect(service).to receive(:rand).and_return 1, 1, 6, 6, 6
          end

          it "loses 2 defenders" do
            action = service.call.actions[0]
            units_lost = action.units_difference

            expect(units_lost).to eq -2
          end
        end

        context "the defender has lost all their units" do
          before do
            expect(service).to receive(:rand).and_return 1, 1, 6, 6, 6, 1, 1, 6, 6, 6
            2.times { service.call }
          end

          it "loses the territory to the attacker" do
            expect(service).to receive(:rand).and_return 1, 6, 6, 6
            event = service.call

            remove_defenders = event.actions[0]
            reinforce_territory = event.actions[1]
            remove_from_attacking_territory = event.actions[2]

            expect(remove_defenders.units_difference).to eq -1
            expect(reinforce_territory.units_difference).to eq 1
            expect(remove_from_attacking_territory.units_difference).to eq -1
          end
        end
      end
    end
  end
end
