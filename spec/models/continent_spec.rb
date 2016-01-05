require 'rails_helper'

RSpec.describe Continent, type: :model do
  let(:continent) { create(:continent) }

  describe "#game" do
    it "is required" do
      continent.game = nil
      expect(continent).not_to be_valid
    end
  end

  describe "#color" do
    it "is required" do
      continent.color = nil
      expect(continent).not_to be_valid
    end
  end
end
