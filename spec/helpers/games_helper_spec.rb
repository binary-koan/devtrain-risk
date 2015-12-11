require "rails_helper"

RSpec.describe GamesHelper, type: :helper do
  fixtures :games, :players

  describe "#player_color" do
    it "should return a different colour for player 1 and 2" do
      player1_color = player_color(games(:game).players, players(:player1))
      player2_color = player_color(games(:game).players, players(:player2))
      expect(player1_color).not_to eq player2_color
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
