require "rails_helper"
require_relative "../../app/concepts/game_state"
require_relative "../../app/services/perform_fortify"
require_relative "../../app/services/perform_attack"


RSpec.describe PerformAttack do
  def remove_units_from_territory(player, territory, units)
    event = Event.attack(
      game: game_state.game,
      player: player
    ).tap { |e| e.save!}

    event.actions.create!(
      territory:        territory,
      territory_owner:  player,
      units_difference: -units
    )
  end

  let(:service) do
    PerformFortify.new(
      territory_from:   territories(territory_from),
      territory_to:     territories(territory_to),
      game_state:       game_state,
      fortifying_units: fortifying_units
    )
  end

  describe "#call" do
    fixtures :games, :players, :territories, :territory_links, :events, :actions
    let(:game_state) { GameState.new(games(:game)) }
    let(:fortifying_units) { 1 }
    let(:player1) { players(:player1) }
    let(:player2) { players(:player2) }

    context "fortifying from territory that is not current players" do
      let(:territory_from) { :territory_bottom_left }
      let(:territory_to) { :territory_top_left }

      it "returns a wrong player error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :wrong_player
      end
    end

    context "fortifying from territory to another with no valid link" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_bottom_right }

      it "returns a no link error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :no_link
      end
    end

    context "fortifying an enemies territory" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_bottom_left }

      it "returns a fortifying_enemy_territory error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :fortifying_enemy_territory
      end
    end

    context "fortifying the same territory" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_left }

      it "returns a same_territory error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :same_territory
      end
    end

    context "fortifying less than the minimum number of units" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_right }
      let(:fortifying_units) { 0 }

      it "returns a minimum_number_of_units error" do
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :minimum_number_of_units
      end
    end

    context "fortifying from territory with only one unit" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_right }

      it "returns a fortify_with_one_unit error" do
        remove_units_from_territory(player1, territories(:territory_top_left), 4)
        expect(service.call).to be false
        expect(service.errors).to contain_exactly :fortify_with_one_unit
      end
    end

    context "fortifying a valid territory" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_right }
      let(:fortifying_units) { 3 }

      it "has no errors" do
        expect(service.call).to be true
        expect(service.errors).to be_none
      end

      before { service.call }

      let(:receiving_action) { service.fortify_event.actions[0] }

      it "adds units to the fortified territory" do
        expect(receiving_action.units_difference).to be 3
      end

      it "adds the units to the correct territory" do
        expect(receiving_action.territory).to be territories(:territory_top_right)
      end

      it "doesn't change the ownership of the receiving territory" do
        expect(receiving_action.territory_owner).to eq player1
      end

      let(:sending_action) { service.fortify_event.actions[1] }

      it "removes units from the fortifying territory" do
        expect(sending_action.units_difference).to be -3
      end

      it "removes the units from the correct territory" do
        expect(sending_action.territory).to be territories(:territory_top_left)
      end

      it "doesn't change the ownership of the sending territory" do
        expect(sending_action.territory_owner).to eq player1
      end
    end
  end
end
