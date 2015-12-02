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

    context "fortifying from territory that is not current players" do
      let(:territory_from) { :territory_bottom_left }
      let(:territory_to) { :territory_top_left }

      before { service.call }

      it "returns a wrong player error" do
         expect(service.errors).to contain_exactly :wrong_player
      end
    end

    context "fortifying from territory to another with no valid link" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_bottom_right }

      before { service.call }

      it "returns a no link error" do
        expect(service.errors).to contain_exactly :no_link
      end
    end

    context "fortifying an enemies territory" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_bottom_left }

      before { service.call }

      it "returns a fortifying_enemy_territory error" do
        expect(service.errors).to contain_exactly :fortifying_enemy_territory
      end
    end

    context "fortifying the same territory" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_left }

      before { service.call }

      it "returns a same_territory error" do
        expect(service.errors).to contain_exactly :same_territory
      end
    end

    context "fortifying a valid territory" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_right }

      let(:fortify_event) { service.call }

      it "has no errors" do
        expect(service.errors).to be_none
      end

      let(:action) { fortify_event.actions[0] }

      it "adds units to the fortified territory" do
        expect(action.units_difference).to be PerformFortify::MINIMUM_FORTIFYING_UNITS
      end
    end

    context "fortifying less than the minimum number of units" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_right }
      let(:fortifying_units) { 0 }

      before { service.call }

      it "returns a minimum_number_of_units error" do
        expect(service.errors).to contain_exactly :minimum_number_of_units
      end

    end

    context "fortifying from territory with only one unit" do
      let(:territory_from) { :territory_top_left }
      let(:territory_to) { :territory_top_right }

      it "returns a fortify_with_one_unit error" do
        remove_units_from_territory(players(:player1), territories(:territory_top_left), 4)
        service.call
        expect(service.errors).to contain_exactly :fortify_with_one_unit
      end
    end
  end
end
