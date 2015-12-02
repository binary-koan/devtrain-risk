require "rails_helper"
require_relative "../../app/concepts/game_state"
require_relative "../../app/services/perform_attack"


RSpec.describe PerformAttack do
  def remove_two_defenders
    expect(service).to receive(:rand).and_return 1, 1, 6, 6, 6
    service.call
  end

  def remove_two_attackers
    allow(service).to receive(:rand).and_return 6
    service.call
  end

  let(:service) do
    PerformAttack.new(
      territory_from: territories(territory_from),
      territory_to:   territories(territory_to),
      game_state:     game_state
    )
  end

  describe "#call" do
    fixtures :games, :players, :territories, :territory_links, :events, :actions
    let(:game_state) { GameState.new(games(:game)) }

    context "attacking from territory that is not current players" do
      let(:territory_from) { :territory_bottom_left }
      let(:territory_to) { :territory_top_left }

      it "returns a wrong player error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :wrong_player
      end
    end

    context "attacking and defending the same territory" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_left }

      it "returns a no link error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :no_link
      end
    end

    context "attacking players own territory" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_right }

      it "indicates that it is not a valid move" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :own_territory
      end
    end

    context "attacking an enemie's territory" do
      context "when the territory isn't a neighbour" do
        let(:territory_from) { :territory_top_left }
        let(:territory_to) { :territory_bottom_right }

        it "returns a no link error" do
          expect(service.call).to be false
          expect(service.errors).to contain_exactly :no_link
        end
      end

      context "the attacker only has one unit left" do
        let(:territory_from) { :territory_top_left }
        let(:territory_to) { :territory_bottom_left }

        before do
          2.times { remove_two_attackers }
        end

        it "returns a cannot attack with one unit error" do
          expect(service.call).to be false
          expect(service.errors).to contain_exactly :cannot_attack_with_one_unit
        end
      end

      context "the territory is a neighbour" do
        let(:territory_from) { :territory_top_left }
        let(:territory_to) { :territory_bottom_left }

        it "has no errors" do
          expect(service.call).to be true
          expect(service.errors).to be_none
        end

        context "the attackers and defenders rolls match" do
          before do
            allow(service).to receive(:rand).and_return 6
          end

          before { service.call }

          let(:action) { service.attack_event.actions[0] }

          it "removes 2 attackers" do
            units_lost = action.units_difference
            expect(units_lost).to eq -2
          end

          it "removes from the correct territory" do
            territory = action.territory
            expect(territory).to eq territories(:territory_top_left)
          end

          it "doesn't change the ownership of the territory" do
            territory_owner = action.territory_owner
            expect(territory_owner).to eq players(:player1)
          end
        end

        context "the defender loses units" do
          before do
            expect(service).to receive(:rand).and_return 1, 1, 6, 6, 6
          end

          before { service.call }

          let(:action) { service.attack_event.actions[0] }

          it "loses 2 defenders" do
            units_lost = action.units_difference
            expect(units_lost).to eq -2
          end

          it "removes from the correct territory" do
            territory = action.territory
            expect(territory).to eq territories(:territory_bottom_left)
          end

          it "doesn't change the ownership of the territory" do
            territory_owner = action.territory_owner
            expect(territory_owner).to eq players(:player2)
          end
        end

        context "the defender has lost all their units" do
          before do
            2.times { remove_two_defenders }
          end

          let(:attack_event) do
            expect(service).to receive(:rand).and_return 1, 6, 6, 6
            service.call
            service.attack_event
          end

          context "removing the defenders from defeated territory" do
            let(:remove_defenders_action) { attack_event.actions[0] }

            it "removes units from the defending territory" do
              expect(remove_defenders_action.units_difference).to eq -1
            end

            it "removes units from the correct territory" do
              expect(remove_defenders_action.territory).to eq territories(:territory_bottom_left)
            end

            it "doesn't change the ownership of the territory" do
              expect(remove_defenders_action.territory_owner).to eq players(:player2)
            end
          end

          context "adding attackers units to defeated territory" do
            let(:reinforce_territory_action) { attack_event.actions[1] }

            it "adds the attacking units to the defeated territory" do
              expect(reinforce_territory_action.units_difference).to eq 1
            end

            it "adds units to the defeated territory" do
              expect(reinforce_territory_action.territory).to eq territories(:territory_bottom_left)
            end

            it "changes the owner of the territory to the attacker" do
              expect(reinforce_territory_action.territory_owner).to eq players(:player1)
            end
          end

          context "removing attack units from attacking territory" do
            let(:remove_attackers_from_territory) { attack_event.actions[2] }

            it "removes the attacking units from the attacking territory" do
              expect(remove_attackers_from_territory.units_difference).to eq -1
            end

            it "removes units from the correct attacking territory" do
              expect(remove_attackers_from_territory.territory).to eq territories(:territory_top_left)
            end

            it "doesn't change the ownership of the territory" do
              expect(remove_attackers_from_territory.territory_owner).to eq players(:player1)
            end
          end
        end
      end
    end
  end
end
