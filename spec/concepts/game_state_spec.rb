require "rails_helper"

RSpec.describe GameState do
  let(:game)    { create(:game) }

  let(:player1) { create(:player, game: game) }
  let(:player2) { create(:player, game: game) }
  let(:jupiter) { create(:territory, game: game) }
  let(:mars)    { create(:territory, game: game) }

  #TODO is there a non-horrible way to do this?
  before do
    player1
    player2
    jupiter
    mars
  end

  subject(:game_state) { GameState.new(game) }

  let(:events)  { [] }

  before        { game_state.apply_events(events) }

  describe "#winning_player" do
    subject { game_state.winning_player }

    context "with no territories owned" do
      it { is_expected.to be_nil }
    end

    context "each player owns one territory" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, game: game, territory: mars),
          create(:reinforce_event, player: player2, game: game, territory: jupiter)
        ]
      end

      it { is_expected.to be_nil }
    end

    context "player 1 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, game: game, territory: mars),
          create(:reinforce_event, player: player1, game: game, territory: jupiter)
        ]
      end

      it { is_expected.to eq player1 }
    end

    context "player 2 owns both territories" do
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
    let(:events) do
      [create(:start_turn_event, game: game, player: player1)]
    end

    context "when one player has started their turn" do
      it { is_expected.to eq player1 }
    end

    context "when the other player has also started their turn" do
      before do
        game_state.apply_events([create(:start_turn_event, game: game, player: player2)])
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
      let(:events) { [create(:reinforce_event, player: player1, game: game, territory: jupiter)] }

      it "contains the territory for the owning player" do
        expect(game_state.owned_territories(player1)).to contain_exactly(jupiter)
      end

      it "is still empty for the other player" do
        expect(game_state.owned_territories(player2)).to be_empty
      end
    end

    context "when both players own one territory" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, game: game, territory: mars),
          create(:reinforce_event, player: player2, game: game, territory: jupiter)
        ]
      end

      it "contains the correct territory for player 1" do
        expect(game_state.owned_territories(player1)).to contain_exactly(mars)
      end

      it "contains the correct territory for player 2" do
        expect(game_state.owned_territories(player2)).to contain_exactly(jupiter)
      end

      context "when one player has taken over the other one's territory" do
        before do
          game_state.apply_events([
            create(:takeover_event, player: player1, game: game, territory: jupiter)
          ])
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
end
