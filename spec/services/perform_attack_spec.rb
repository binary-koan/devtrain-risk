require "spec_helper"
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
      context "the territory is a neighbour" do
        let(:service) { create_attack(:territory_top_left, :territory_bottom_left) }

        subject { service.call }

        it { is_expected.to_not be nil }

        before { service.call }

        it "has no errors" do
          expect(service.errors).to be_none

        end
      end

      # expect(service).to receive(:rand).and_return 6,5,4,3,2

      context "when the territory isn't a neighbour" do
        let(:service) { create_attack(:territory_top_left, :territory_bottom_right) }

        subject { service.call }

        it { is_expected.to be nil }

        before { service.call }

        it "returns a no link error" do
          expect(service.errors[0]).to be :no_link
        end
      end
    end
  end
end
