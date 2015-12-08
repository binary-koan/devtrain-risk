require "rails_helper"

RSpec.describe GameState do
  let(:game)   { create(:game) }

  let!(:player1) { create(:player, game: game) }
  let!(:player2) { create(:player, game: game) }
  let!(:jupiter) { create(:territory, game: game) }
  let!(:mars)    { create(:territory, game: game) }

  let(:events) { [create(:mock_event, player: player1)] }

  subject(:turn) { BuildTurn.new(events).call }
  subject(:game_state) { turn.game_state }

  describe "#won?" do
    subject { game_state.won? }

    context "when each player owns one territory" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, territory: mars),
          create(:reinforce_event, player: player2, territory: jupiter)
        ]
      end

      it { is_expected.to eq false }
    end

    context "when player 1 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, territory: mars),
          create(:reinforce_event, player: player1, territory: jupiter)
        ]
      end

      it { is_expected.to eq true }
    end

    context "when player 2 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player2, territory: mars),
          create(:reinforce_event, player: player2, territory: jupiter)
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
          create(:reinforce_event, player: player1, territory: mars),
          create(:reinforce_event, player: player2, territory: jupiter)
        ]
      end

      it { is_expected.to be_nil }
    end

    context "when player 1 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player1, territory: mars),
          create(:reinforce_event, player: player1, territory: jupiter)
        ]
      end

      it { is_expected.to eq player1 }
    end

    context "when player 2 owns both territories" do
      let(:events) do
        [
          create(:reinforce_event, player: player2, territory: mars),
          create(:reinforce_event, player: player2, territory: jupiter)
        ]
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
        [create(:reinforce_event, player: player1, territory: jupiter)]
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
          create(:reinforce_event, player: player1, territory: mars),
          create(:reinforce_event, player: player2, territory: jupiter)
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
            create(:takeover_event, player: player1, territory: jupiter)
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
        create(:reinforce_event, player: player1, territory: mars),
        create(:reinforce_event, player: player2, territory: jupiter)
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

  describe "#units_on_territory" do
    let(:base_events) do
      [create(:reinforce_event, player: player1, territory: jupiter, units_difference: 3)]
    end

    let(:events) { base_events }

    subject { game_state.units_on_territory(jupiter) }

    context "when one event has affected the territory" do
      it { is_expected.to eq 3 }
    end

    context "when multiple events have affected the territory" do
      let(:events) do
        base_events + [
          create(:attack_event, player: player2, territory: jupiter, units_difference: -2),
          create(:reinforce_event, player: player1, territory: jupiter, units_difference: 1)
        ]
      end

      it { is_expected.to eq 3 - 2 + 1 }
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
