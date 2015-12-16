require "rails_helper"

RSpec.describe StartNextTurn do
  fixtures :games, :players

  context "#call" do
    let(:game) { games(:game) }
    let(:game_state) { instance_double(GameState, in_game?: true) }

    let(:turn) do
      instance_double(Turn,
        game: games(:game),
        player: players(:player1),
        game_state: game_state,
        can_start_next_turn?: true
      )
    end

    subject(:service) { StartNextTurn.new(turn) }

    context "when the turn can be ended" do
      it "succeeds and adds a start turn event to the game" do
        expect(service.call).to eq true
        expect(game.events.last.event_type).to eq "start_turn"
        expect(game.events.last.player).to eq players(:player2)
      end
    end

    context "when the turn cannot be ended" do
      before { expect(turn).to receive(:can_start_next_turn?).and_return(false) }

      it "fails with an error" do
        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :wrong_phase
      end
    end

    context "when a player is out of the game" do
      before { expect(game_state).to receive(:in_game?).and_return(false, true) }

      it "skips the player who is out and starts the next player's turn" do
        expect(service.call).to eq true
        expect(game.events.last.event_type).to eq "start_turn"
        expect(game.events.last.player).to eq players(:player3)
      end
    end
  end
end
