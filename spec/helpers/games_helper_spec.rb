require "rails_helper"

RSpec.describe GamesHelper, type: :helper do
  fixtures :all

  describe "#owned_territory_names" do
    let(:turn) { BuildTurn.new(games(:game).events).call }

    it "returns the names of the territories the player owns" do
      expect(owned_territory_names(turn)).to eq ["Jupiter", "Mars"]
    end
  end

  describe "#enemy_territory_names" do
    let(:turn) { BuildTurn.new(games(:game).events).call }

    it "returns the names of the territories the player does not own" do
      expect(enemy_territory_names(turn)).to eq ["Mercury", "Saturn"]
    end

    it "is the complement of owned_territory_names" do
      territories = owned_territory_names(turn) + enemy_territory_names(turn)
      expect(games(:game).territories.pluck(:name)).to contain_exactly(*territories)
    end
  end

  describe "#player_color" do
    it "returns a different colour for player 1 and 2" do
      player1_color = player_color(games(:game).players, players(:player1))
      player2_color = player_color(games(:game).players, players(:player2))
      expect(player1_color).not_to eq player2_color
    end
  end

  describe "#available_maps" do
    it "returns the list of available maps" do
      expect(available_maps).to eq ["default", "botte_neck", "star", "ring", "MOBA"]
    end
  end

  describe "#map_display" do
    let(:turn) { BuildTurn.new(games(:game).events).call }

    let(:svg) { Nokogiri::XML(map_display(turn)) }

    it "renders lines for links between territories" do
      expect(svg.css("line").size).to eq 4
    end

    it "renders circles for territories" do
      expect(svg.css("circle").size).to eq 4
    end

    it "renders territory names" do
      ["Jupiter", "Mars", "Saturn", "Mercury"].each do |territory|
        expect(svg.search("[text()='#{territory}']").size).to eq 1
      end
    end

    it "renders the number of units on territories" do
      expect(svg.search("[text()='5 units']").size).to eq 4
    end
  end
end
