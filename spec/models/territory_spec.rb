require 'rails_helper'

RSpec.describe Territory, type: :model do
  let(:territory) { create(:territory, name: "Jupiter") }

  describe "#game" do
    it "is required" do
      territory.game = nil
      expect(territory).to_not be_valid
    end
  end

  describe "#connected_territories" do
    let(:second_territory) { create(:territory, name: "Mars") }
    let(:third_territory) { create(:territory, name: "Saturn") }

    context "with a link from this territory" do
      before do
        create(:territory_link, from_territory: territory, to_territory: second_territory)
      end

      it "contains the linked territory" do
        expect(territory.connected_territories).to contain_exactly(second_territory)
      end
    end

    context "with a link to this territory" do
      before do
        create(:territory_link, from_territory: territory, to_territory: second_territory)
      end

      it "contains the linked territory" do
        expect(territory.connected_territories).to contain_exactly second_territory
      end
    end

    context "with links to and from this territory" do
      before do
        create(:territory_link, from_territory: territory, to_territory: second_territory)
        create(:territory_link, from_territory: third_territory, to_territory: territory)
      end

      it "contains both linked territories" do
        expect(territory.connected_territories).to contain_exactly(second_territory, third_territory)
      end
    end

    context "with a directly and indirectly linked territory" do
      before do
        create(:territory_link, from_territory: territory, to_territory: second_territory)
        create(:territory_link, from_territory: second_territory, to_territory: third_territory)
      end

      it "only contains the directly linked territory" do
        expect(territory.connected_territories).to contain_exactly(second_territory)
      end
    end
  end
end
