require "spec_helper"
require_relative "../../app/concepts/game_state"
require_relative "../../app/services/perform_attack"


RSpec.describe PerformAttack do
  describe "#call" do
    fixtures :territories
    fixtures :games
    let(:game_state) { GameState.new(games(:game)) }
    let(:service) { PerformAttack.new(territory_from: territories(:territory_top_left),
                                      territory_to: territories(:territory_top_right),
                                      game_state: game_state) }
    # subject(:result) { service.call }
    #
    # it { is_expected.to_be false }

    it "exists" do
      puts game_state
    end

  end
end
