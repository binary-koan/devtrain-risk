require 'rails_helper'

RSpec.describe Action, type: :model do
  let(:action) { create(:action) }

  describe "#event" do
    it "is required" do
      action.event = nil
      expect(action).not_to be_valid
    end
  end

  describe "#territory" do
    it "is required" do
      action.territory = nil
      expect(action).not_to be_valid
    end
  end

  describe "#territory_owner" do
    it "is required" do
      action.territory_owner = nil
      expect(action).not_to be_valid
    end
  end

  describe "#units_difference" do
    it "can be positive" do
      action.units_difference = 10
      expect(action).to be_valid
    end

    it "can be negative" do
      action.units_difference = -10
      expect(action).to be_valid
    end

    it "cannot be zero" do
      action.units_difference = 0
      expect(action).not_to be_valid
    end
  end
end
