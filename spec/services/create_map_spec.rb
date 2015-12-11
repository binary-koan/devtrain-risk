require "rails_helper"

RSpec.describe CreateMap do
  describe "#call" do
    let(:game) { Game.create! }
    let(:service) { CreateMap.new(game: game, map_name: map_name) }
    let(:result) { service.call }
    let(:map_name) { "default" }

    context "when creating an invalid map" do
      let(:map_name) { "bad_map" }

      it "returns an empty with a not_valid_map_name error" do
        expect(result).to be_empty
        expect(service.errors).to contain_exactly :not_valid_map_name
      end
    end

    context "when no map_name is given" do
      it "creates the default map" do
        expect(result.size).to be 6
        expect(game.territories.size).to be 6
        expect(service.errors).to be_empty
      end
    end

    context "when a valid map_name is given" do
      let(:map_name) { "star" }

      it "creates the specified map" do
        expect(result.size).to be 19
        expect(game.territories.size).to be 19
        expect(service.errors).to be_empty
      end
    end
  end
end
