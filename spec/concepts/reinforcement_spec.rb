require "rails_helper"

RSpec.describe Reinforcement do
  fixtures :territories

  let(:game_state) { instance_double(GameState) }
  let(:player) { instance_double(Player) }
  let(:turn) { instance_double(Turn, game_state: game_state, player: player) }

  let(:owned_territories) do
    [territories(:territory_top_left), territories(:territory_top_right)]
  end

  subject(:reinforcement) { Reinforcement.new(turn) }

  before do
    expect(game_state).to receive(:owned_territories).with(player).and_return(owned_territories)
  end

  describe "#remaining_units" do
    subject { reinforcement.remaining_units }

    context "when the player owns fewer than three territories" do
      it { is_expected.to eq 3 }
    end

    context "when the player owns more than three territories" do
      let(:owned_territories) do
        [
          territories(:territory_top_left),
          territories(:territory_top_right),
          territories(:territory_bottom_left),
          territories(:territory_bottom_right)
        ]
      end

      it { is_expected.to eq 4 }
    end
  end

  describe "#remove" do
    it "fails if trying to remove too many units" do
      expect(reinforcement.remove(4)).to eq false
    end

    it "removes the units from the remaining count" do
      reinforcement.remove(2)
      expect(reinforcement.remaining_units).to eq 1
    end
  end

  describe "#remaining?" do
    it "is false if passed a larger number than the units remaining" do
      expect(reinforcement.remaining?(4)).to eq false
    end

    it "is true if passed the number remaining" do
      expect(reinforcement.remaining?(3)).to eq true
    end

    it "is true if passed a smaller number than the units remaining" do
      expect(reinforcement.remaining?(1)).to eq true
    end
  end

  describe "#none?" do
    it "is false when no units have been removed" do
      expect(reinforcement.none?).to eq false
    end

    it "is false when some units have been removed" do
      reinforcement.remove(2)
      expect(reinforcement.none?).to eq false
    end

    it "is true when all units have been removed" do
      reinforcement.remove(3)
      expect(reinforcement.none?).to eq true
    end
  end
end
