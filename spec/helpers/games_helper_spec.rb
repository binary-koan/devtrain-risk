RSpec.describe GamesHelper, type: :helper do
  fixtures :games, :players

  describe "#player_color" do
    it "should return a different colour for player 1 and 2" do
      player1_color = player_color(games(:game), players(:player1))
      player2_color = player_color(games(:game), players(:player2))
      expect(player1_color).not_to eq player2_color
    end
  end
end
