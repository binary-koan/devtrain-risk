require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:player) { create(:player) }

  describe "#game" do
    it "is required" do
      player.game = nil
      expect(player).to_not be_valid
    end
  end

  describe "#name" do
    it "is required" do
      player.name = nil
      expect(player).to_not be_valid
    end

    it "cannot be too short" do
      player.name = ""
      expect(player).to_not be_valid
    end

    it "cannot be too long" do
      player.name = "a" * 101
      expect(player).to_not be_valid
    end
  end
end
