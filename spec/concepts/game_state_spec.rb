require "rails_helper"

RSpec.describe GameState do
  let(:game)   { create(:game) }

  let!(:player1) { create(:player, game: game) }
  let!(:player2) { create(:player, game: game) }
  let!(:jupiter) { create(:territory, game: game) }
  let!(:mars)    { create(:territory, game: game) }

  let(:events) { [] }

  subject(:game_state) { BuildGameState.new(game, events).call }

  describe "#player_color" do
    it "should return a different colour for player 1 and 2" do
      player1_color = game_state.player_color(game.players[0])
      player2_color = game_state.player_color(game.players[1])
      expect(player1_color).not_to eq player2_color
    end
  end

  describe "#won?" do
    subject { game_state.won? }

    context "when each player owns one territory" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, game: game, territory: mars),
          create(:reinforce_event, player: player2, game: game, territory: jupiter)
        ]
      end

      it { is_expected.to eq false }
    end

    context "when player 1 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, game: game, territory: mars),
          create(:reinforce_event, player: player1, game: game, territory: jupiter)
        ]
      end

      it { is_expected.to eq true }
    end

    context "when player 2 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player2, game: game, territory: mars),
          create(:reinforce_event, player: player2, game: game, territory: jupiter)
        ]
      end

      it { is_expected.to eq true }
    end
  end

  describe "#winning_player" do
    subject { game_state.winning_player }

    context "when each player owns one territory" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, game: game, territory: mars),
          create(:reinforce_event, player: player2, game: game, territory: jupiter)
        ]
      end

      it { is_expected.to be_nil }
    end

    context "when player 1 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, game: game, territory: mars),
          create(:reinforce_event, player: player1, game: game, territory: jupiter)
        ]
      end

      it { is_expected.to eq player1 }
    end

    context "when player 2 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player2, game: game, territory: mars),
          create(:reinforce_event, player: player2, game: game, territory: jupiter)
        ]
      end

      it { is_expected.to eq player2 }
    end
  end

  describe "#current_player" do
    subject { game_state.current_player }

    let(:base_event) do
      [create(:start_turn_event, game: game, player: player1)]
    end

    let(:events) { base_event }

    context "when one player has started their turn" do
      it { is_expected.to eq player1 }
    end

    context "when the other player has also started their turn" do
      let(:events) do
        base_event + [create(:start_turn_event, game: game, player: player2)]
      end

      it { is_expected.to eq player2 }
    end
  end

  describe "#owned_territories" do
    context "with no territories owned" do
      it "is empty for both players" do
        expect(game_state.owned_territories(player1)).to be_empty
        expect(game_state.owned_territories(player2)).to be_empty
      end
    end

    context "when one player owns one territory" do
      let(:events) do
        [create(:reinforce_event, player: player1, game: game, territory: jupiter)]
      end

      it "contains the territory for the owning player" do
        expect(game_state.owned_territories(player1)).to contain_exactly(jupiter)
      end

      it "is still empty for the other player" do
        expect(game_state.owned_territories(player2)).to be_empty
      end
    end

    context "when both players own one territory" do
      let(:base_events) do
        [
          create(:reinforce_event, player: player1, game: game, territory: mars),
          create(:reinforce_event, player: player2, game: game, territory: jupiter)
        ]
      end

      let(:events) { base_events }

      it "contains the correct territory for player 1" do
        expect(game_state.owned_territories(player1)).to contain_exactly(mars)
      end

      it "contains the correct territory for player 2" do
        expect(game_state.owned_territories(player2)).to contain_exactly(jupiter)
      end

      context "when one player has taken over the other one's territory" do
        let(:events) do
          base_events + [
            create(:takeover_event, player: player1, game: game, territory: jupiter)
          ]
        end

        it "contains both territories for player 1" do
          expect(game_state.owned_territories(player1)).to contain_exactly(jupiter, mars)
        end

        it "is empty for player 2" do
          expect(game_state.owned_territories(player2)).to be_empty
        end
      end
    end
  end

  describe "#territory_owner" do
    let(:events) do
      [
        create(:reinforce_event, player: player1, game: game, territory: mars),
        create(:reinforce_event, player: player2, game: game, territory: jupiter)
      ]
    end

    it "is the inverse of #owned_territories for player 1" do
      owned_territories = game_state.owned_territories(player1)
      expect(owned_territories).to be_all { |t| game_state.territory_owner(t) == player1 }
    end

    it "is the inverse of #owned_territories for player 2" do
      owned_territories = game_state.owned_territories(player2)
      expect(owned_territories).to be_all { |t| game_state.territory_owner(t) == player2 }
    end
  end

  describe "#territory_links" do
    before do
      create(:territory_link, from_territory: jupiter, to_territory: mars)
    end

    subject { game_state.territory_links }

    context "with a link from one territory to another" do
      it { is_expected.to contain_exactly([jupiter, mars]) }
    end

    context "with multiple links between territories" do
      let(:saturn) { create(:territory, game: game) }

      before do
        create(:territory_link, from_territory: saturn, to_territory: mars)
        create(:territory_link, from_territory: saturn, to_territory: jupiter)
      end

      it { is_expected.to contain_exactly([jupiter, mars], [saturn, mars], [saturn, jupiter]) }
    end
  end
end
