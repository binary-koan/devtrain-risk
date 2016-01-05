require "rails_helper"

RSpec.describe StartNextTurn do
  fixtures :games, :players

  context "#call" do
    let(:game) { games(:game) }

    let(:allowed_events) do
      instance_double(GetAllowedEvents, call: [Event.start_turn.new])
    end

    let(:game_state) do
      instance_double(GameState,
        game: games(:game),
        current_player: players(:player1),
        in_game?: true
      )
    end

    subject(:service) { StartNextTurn.new(game_state) }

    before { allow(GetAllowedEvents).to receive(:new).and_return(allowed_events) }

    context "when the turn can be ended" do
      it "succeeds and adds a start turn event to the game" do
        expect(service.call).to eq true
        expect(game.events.last.event_type).to eq "start_turn"
        expect(game.events.last.player).to eq players(:player2)
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
