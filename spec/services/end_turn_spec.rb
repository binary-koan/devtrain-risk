RSpec.describe EndTurn do
  fixtures :games

  context "#call" do
    let(:game) { games(:game) }
    let(:game_state) { BuildGameState.new(game, game.events).call }
    let(:service) { EndTurn.new(game_state) }
    let(:perform_reinforce) { instance_double(PerformReinforce) }

    before { service.call }

    it "added a start turn event to the game" do
      expect(game.events.last.event_type).to eq "start_turn"
    end
  end
end
