require 'rails_helper'

RSpec.describe Territory, type: :model do
  let(:territory) { create(:territory) }

  describe "#game" do
    it "is required" do
      territory.game = nil
      expect(territory).to_not be_valid
    end
  end
end
