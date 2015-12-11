require "rails_helper"

RSpec.describe PerformFortify do
  def kill_on_territory(territory, player, count)
    create(
      :attack_event,
      player: player,
      territory: territory,
      units: count
    )
  end

  let(:game) { games(:game) }
  let(:player) { players(:player1) }

  before do
    create(
      :reinforce_event,
      player: player,
      territory: territories(:territory_top_left)
    )
  end

  let(:events) { game.events }

  let(:turn) { BuildTurn.new(events).call }
  let(:game_state) { turn.game_state }

  let(:service) do
    PerformFortify.new(
      territory_from:   territory_from,
      territory_to:     territory_to,
      turn:             turn,
      fortifying_units: fortifying_units
    )
  end

  describe "#call" do
    fixtures :games, :players, :territories
    let(:fortifying_units) { 1 }

    context "fortifying from territory that is not current players" do
      let(:territory_from) { territories(:territory_bottom_left) }
      let(:territory_to) { territories(:territory_top_left) }

      it "returns a wrong player error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :wrong_player
      end
    end

    context "fortifying from territory to another with no valid link" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_bottom_right) }

      it "returns a no link error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :no_link
      end
    end

    context "fortifying an enemies territory" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_bottom_left) }

      it "returns a fortifying_enemy_territory error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :fortifying_enemy_territory
      end
    end

    context "fortifying the same territory" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_left) }

      it "returns a same_territory error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :same_territory
      end
    end

    context "fortifying less than the minimum number of units" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_right) }
      let(:fortifying_units) { 0 }

      it "returns a not_enough_fortifying_units error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :not_enough_fortifying_units
      end
    end

    context "fortifying from territory with only one unit" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_right) }

      it "returns a fortifying_too_many_units error" do
        kill_on_territory(territory_from, player, 7)
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :fortifying_too_many_units
      end
    end

    context "fortifying with more units than territory has" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_right) }
      let(:fortifying_units) { 10 }

      it "returns a fortifying_too_many_units error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :fortifying_too_many_units
      end
    end

    context "fortifying all the units on a territory" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_right) }
      let(:fortifying_units) { 8 }

      it "returns a fortifying_too_many_units error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :fortifying_too_many_units
      end
    end

    context "fortifying a valid territory" do
      let(:territory_from) { territories(:territory_top_left) }
      let(:territory_to) { territories(:territory_top_right) }
      let(:fortifying_units) { 3 }

      context "when there has already been a fortify event" do
        before do
          create(:fortify_event, player: player, territory_from: territory_from, territory_to: territory_to)
        end

        it "fails with an error" do
          expect(service.call).to eq false
          expect(service.errors).to contain_exactly :wrong_phase
        end
      end

      context "when there has not yet been a fortify event" do
        let!(:result) { service.call }

        it "has no errors" do
          expect(result).to eq true
          expect(service.errors).to be_none
        end

        describe "the receiving action" do
          subject(:action) { service.fortify_event.action }

          it "adds units to the fortified territory" do
            expect(action.units).to be 3
            expect(action.territory_to).to eq territory_to
            expect(action.territory_from).to eq territory_from
          end

          it "doesn't change the ownership of the territories" do
            expect(service.fortify_event.player).to eq player
          end
        end
      end
    end
  end
end
