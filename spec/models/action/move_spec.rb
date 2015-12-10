require 'rails_helper'

RSpec.describe Action::Move, type: :model do
  let(:action) { create(:action_move) }

  describe "#territory_from" do
    it "is required" do
      action.territory_from = nil
      expect(action).not_to be_valid
    end
  end

  describe "#territory_to" do
    it "is required" do
      action.territory_to = nil
      expect(action).not_to be_valid
    end
  end

  describe "#units" do
    it "can be positive" do
      action.units = 10
      expect(action).to be_valid
    end

    it "cannot be negative" do
      action.units = -10
      expect(action).not_to be_valid
    end

    it "cannot be zero" do
      action.units = 0
      expect(action).not_to be_valid
    end
  end
end
