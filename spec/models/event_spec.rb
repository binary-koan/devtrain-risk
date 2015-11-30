require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) { create(:event) }

  describe "#event_type" do
    %i{reinforce attack fortify start_turn}.each do |type|
      it "can be #{type}" do
        event.event_type = type
        expect(event).to be_valid
      end
    end

    it "cannot be an invalid type" do
      expect { event.event_type = :nothing }.to raise_error ArgumentError
    end
  end

  describe "#player" do
    it "is required" do
      event.player = nil
      expect(event).not_to be_valid
    end
  end

  describe "#game" do
    it "is required" do
      event.game = nil
      expect(event).not_to be_valid
    end
  end
end
