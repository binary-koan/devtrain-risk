require "rails_helper"

RSpec.describe PerformAttack do
  def kill_on_territory(territory, player, count)
    create(
      :mock_event,
      game: game,
      player: player,
      territory: territory,
      units_difference: -count
    )
  end

  fixtures :games, :players, :territories, :territory_links, :events, :actions

  let(:game) { games(:game) }

  let(:base_events) do
    game.events << create(
      :reinforce_event,
      game: game,
      player: players(:player1),
      territory: territories(:territory_top_left)
    )
  end

  let(:events) { base_events }

  let(:game_state) { BuildGameState.new(game, events).call }
  let(:attacking_units) { 3 }

  let(:service) do
    PerformAttack.new(
      territory_from:  territory_from,
      territory_to:    territory_to,
      game_state:      game_state,
      attacking_units: attacking_units
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

    context "attacking and defending the same territory" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_left) }

      it "returns a no link error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :no_link
      end
    end

    context "attacking players own territory" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_right) }

      it "indicates that it is not a valid move" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :own_territory
      end
    end

    context "attacking an enemie's territory" do
      context "when the territory isn't a neighbour" do
        let(:territory_from) { territories(:territory_top_left) }
        let(:territory_to) { territories(:territory_bottom_right) }

        it "returns a no link error" do
          expect(service.call).to be false
          expect(service.errors).to contain_exactly :no_link
        end
      end

      context "the attacker only has one unit left" do
        let(:territory_from) { territories(:territory_top_left) }
        let(:territory_to) { territories(:territory_bottom_left) }

        let(:events) do
          base_events << kill_on_territory(territory_from, players(:player1), 7)
        end

        it "returns a cannot attack with one unit error" do
          expect(service.call).to be false
          expect(service.errors).to contain_exactly :cannot_attack_with_one_unit
        end
      end

      context "the territory is a neighbour" do
        let(:territory_from) { territories(:territory_top_left) }
        let(:territory_to) { territories(:territory_bottom_left) }

        it "has no errors" do
          expect(service.call).to be true
          expect(service.errors).to be_none
        end

        context "the attacker only attacks with one unit" do
          let(:attacking_units) { 1 }

          it "is a valid move" do
            expect(service.call).to be true
            expect(service.errors).to be_none
          end

          it "only lets the attacker rolls one attacking dice" do
            expect(service).to receive(:rand).and_return 1, 6, 6
            expect(service.call).to be true
          end

          context "the attacker loses the one dice roll" do
            before { service.call }

            let(:action) { service.attack_event.actions[0] }

            it "only removes one attacking unit" do
              expect(action.units_difference).to be -1
            end
          end
        end

        context "the attacker only attacks with two units" do
          let(:attacking_units) { 2 }

          it "is a valid move" do
            expect(service.call).to be true
            expect(service.errors).to be_none
          end

          it "only lets the attack role 2 dice" do
            expect(service).to receive(:rand).exactly(4).times.and_return 1, 1, 6, 6
            expect(service.call).to be true
          end

          context "the attacker loses both dice rolls" do
            before do
              expect(service).to receive(:rand).exactly(4).times.and_return 1, 1, 6, 6
              service.call
            end

            let(:action) { service.attack_event.actions[0] }

            it "removes both of the attacking units" do
              expect(action.units_difference).to be -2
            end
          end
        end

        context "the attacker attacks with four units" do
          let(:attacking_units) { 4 }

          it "is a valid move" do
            expect(service.call).to be false
            expect(service.errors).to contain_exactly :too_many_units
          end
        end

        context "the attackers and defenders rolls match" do
          before do
            allow(service).to receive(:rand).and_return 6
          end

          before { service.call }

          it "removes 2 attackers" do
            units_lost = service.attack_event.actions[0].units_difference
            expect(units_lost).to eq -2
          end

          it "removes from the correct territory" do
            territory = service.attack_event.actions[0].territory
            expect(territory).to eq territories(:territory_top_left)
          end

          it "doesn't change the ownership of the territory" do
            territory_owner = service.attack_event.actions[0].territory_owner
            expect(territory_owner).to eq players(:player1)
          end
        end

        context "the defender loses units" do
          before do
            expect(service).to receive(:rand).and_return 1, 1, 6, 6, 6
          end

          before { service.call }

          it "loses 2 defenders" do
            units_lost = service.attack_event.actions[0].units_difference
            expect(units_lost).to eq -2
          end

          it "removes from the correct territory" do
            territory = service.attack_event.actions[0].territory
            expect(territory).to eq territories(:territory_bottom_left)
          end

          it "doesn't change the ownership of the territory" do
            territory_owner = service.attack_event.actions[0].territory_owner
            expect(territory_owner).to eq players(:player2)
          end
        end

        context "the defender has lost all their units" do
          let(:events) do
            base_events << kill_on_territory(territory_to, players(:player2), 4)
          end

          before do
            expect(service).to receive(:rand).and_return 1, 6, 6, 6
            service.call
          end

          context "removing the defenders from defeated territory" do
            let(:remove_defenders_event) { service.attack_event.actions[0] }

            it "removes units from the defending territory" do
              expect(remove_defenders_event.units_difference).to eq -1
            end

            it "removes units from the correct territory" do
              expect(remove_defenders_event.territory).to eq territories(:territory_bottom_left)
            end

            it "doesn't change the ownership of the territory" do
              expect(remove_defenders_event.territory_owner).to eq players(:player2)
            end
          end

          context "adding attackers units to defeated territory" do
            let(:add_attackers_event) { service.attack_event.actions[1] }

            it "adds the attacking units to the defeated territory" do
              expect(add_attackers_event.units_difference).to eq 1
            end

            it "adds units to the defeated territory" do
              expect(add_attackers_event.territory).to eq territories(:territory_bottom_left)
            end

            it "changes the owner of the territory to the attacker" do
              expect(add_attackers_event.territory_owner).to eq players(:player1)
            end
          end

          context "removing attack units from attacking territory" do
            let(:remove_attackers_event) { service.attack_event.actions[2] }

            it "removes the attacking units from the attacking territory" do
              expect(remove_attackers_event.units_difference).to eq -1
            end

            it "removes units from the correct attacking territory" do
              expect(remove_attackers_event.territory).to eq territories(:territory_top_left)
            end

            it "doesn't change the ownership of the territory" do
              expect(remove_attackers_event.territory_owner).to eq players(:player1)
            end
          end
        end
      end
    end
  end
end
