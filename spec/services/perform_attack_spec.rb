require "spec_helper"
require_relative "../../app/concepts/game_state"
require_relative "../../app/services/perform_attack"


RSpec.describe PerformAttack do
  describe "#call" do
    fixtures :games, :players, :territories, :territory_links, :events, :actions
    let(:game_state) { GameState.new(games(:game)) }

    context "attacking and defending the same territory" do
      let(:service) do
        PerformAttack.new(
          territory_from: territories(:territory_top_left),
          territory_to:   territories(:territory_top_left),
          game_state:     game_state
        )
      end

      let(:result) { service.call }

      it "indicates that it is not a valid move" do
        expect(result).to be false
      end

      before { service.call }

      it "returns a no link error" do
        expect(service.errors[0]).to be :no_link
      end
    end

    context "attacking players own territory" do
      let(:service) do
        PerformAttack.new(
          territory_from: territories(:territory_top_left),
          territory_to:   territories(:territory_top_right),
          game_state:     game_state
        )
      end

      let(:result) { service.call }

      it "indicates that it is not a valid move" do
        expect(result).to be false
      end

      before { service.call }

      it "returns an own territory error" do
        expect(service.errors[0]).to be :own_territory
      end
    end
  end
end
