require 'rails_helper'

RSpec.describe Action::Kill, type: :model do
  let(:action) { create(:action_kill) }

  describe "#territory_from" do
    it "is required" do
      action.territory_from = nil
      expect(action).not_to be_valid
    end
  end

  describe "#territory" do
    it "is required" do
      action.territory = nil
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
