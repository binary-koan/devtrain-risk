require "rails_helper"

RSpec.describe CreateMap do
  describe "#call" do
    let(:game) { create(:game) }
    let(:map_name) { "default" }

    subject(:service) { CreateMap.new(game: game, map_name: map_name) }

    context "when creating an invalid map" do
      let(:map_name) { "bad_map" }

      it "returns an empty with a not_valid_map_name error" do
        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :not_valid_map_name
      end
    end

    context "when no map_name is given" do
      it "creates the default map" do
        expect(service.call).to eq true
        expect(game.territories.size).to eq 6
        expect(game.continents.size).to eq 2
        expect(service.errors).to be_empty
      end
    end

    context "when a valid map_name is given" do
      let(:map_name) { "star" }

      it "creates the specified map" do
        expect(service.call).to eq true
        expect(game.territories.size).to eq 19
        expect(game.continents.size).to eq 3
        expect(service.errors).to be_empty
      end
    end
  end
end
