require "rails_helper"

RSpec.describe EndTurn do
  fixtures :games, :players

  #TODO test skipping "out" players

  context "#call" do
    let(:game) { games(:game) }
    let(:game_state) { instance_double(GameState, in_game?: true) }

    let(:turn) do
      instance_double(Turn,
        game: games(:game),
        player: players(:player1),
        game_state: game_state
      )
    end

    subject(:service) { EndTurn.new(turn) }

    context "when the turn can be ended" do
      before { expect(turn).to receive(:can_end_turn?).and_return(true) }

      it "succeeds and adds a start turn event to the game" do
        expect(service.call).to eq true
        expect(game.events.last.event_type).to eq "start_turn"
      end
    end

    context "when the turn cannot be ended" do
      before { expect(turn).to receive(:can_end_turn?).and_return(false) }

      it "fails with an error" do
        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :wrong_phase
      end
    end
  end
end
