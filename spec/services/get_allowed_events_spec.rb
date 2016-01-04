RSpec.describe GetAllowedEvents do
  #TODO just mock turn instead of all this
  fixtures :games, :players, :territories, :continents, :events, :"action/adds"

  def create_specific_reinforcement(units)
    create(:reinforce_event, player: player, territory: territories(:territory_top_left), units: units)
  end

  def create_incomplete_reinforcement
    create(:reinforce_event, player: player, territory: territories(:territory_top_left), units: 1)
  end

  def create_attack(
      territory_from: territories(:territory_top_right),
      territory_to: territories(:territory_top_left),
      units: 2)
    create(:attack_event, player: player, territory_from: territory_from, territory: territory_to, units: units)
  end

  def create_fortification(
      territory_from: territories(:territory_top_right),
      territory_to: territories(:territory_top_left),
      units: 2)
    create(:fortify_event, player: player, territory_from: territory_from, territory_to: territory_to, units: units)
  end

  let(:game) { games(:game) }
  let(:events) { game.events }
  let(:player) { players(:player1) }

  let(:turn) { Turn.new(events) }

  subject(:service) { GetAllowedEvents.new(turn) }

  describe "#call" do
    subject(:allowed_events) { service.call }

    context "when a turn has just been started" do
      it "only allows a reinforce event" do
        expect(allowed_events.size).to eq 1
        expect(allowed_events.first.event_type).to eq "reinforce"
      end
    end

    context "when a complete reinforcement has been made" do
      let(:reinforcement_units) { 4 }
      before { create_specific_reinforcement(reinforcement_units) }

      it "allows attack, fortify and end turn events" do
        expect(allowed_events).to be_one { |e| e.event_type == "attack" }
        expect(allowed_events).to be_one { |e| e.event_type == "fortify" }
        expect(allowed_events).to be_one { |e| e.event_type == "start_turn" }
      end
    end

    context "when an attack has been made" do
      before { create_attack }

      it "allows attack, fortify and end turn events" do
        expect(allowed_events).to be_one { |e| e.event_type == "attack" }
        expect(allowed_events).to be_one { |e| e.event_type == "fortify" }
        expect(allowed_events).to be_one { |e| e.event_type == "start_turn" }
      end
    end

    context "when a fortify move has been made" do
      before { create_fortification }

      it "only allows an end turn event" do
        expect(allowed_events.size).to eq 1
        expect(allowed_events.first.event_type).to eq "start_turn"
      end
    end

    context "when a fortify move has been made after an attack" do
      before do
        create_attack
        create_fortification
      end

      it "allows attack, fortify and end turn events" do
        expect(allowed_events).to be_one { |e| e.event_type == "attack" }
        expect(allowed_events).to be_one { |e| e.event_type == "fortify" }
        expect(allowed_events).to be_one { |e| e.event_type == "start_turn" }
      end
    end

    context "when a territory has been taken over" do
      before do
        create_attack(
          territory_from: territories(:territory_top_left),
          territory_to: territories(:territory_top_right),
          units: 5
        )
      end

      it "only allows a fortify event" do
        expect(allowed_events.size).to eq 1
        expect(allowed_events.first.event_type).to eq "fortify"
      end

      it "requires the event to be from and to the right territory" do
        action = allowed_events.first.action
        expect(action.territory_from).to eq territories(:territory_top_left)
        expect(action.territory_to).to eq territories(:territory_top_right)
      end

      context "and a correct fortify move has been made" do
        before do
          create_fortification(
            territory_from: territories(:territory_top_left),
            territory_to: territories(:territory_top_right),
            units: 2
          )
        end

        it "allows attack, fortify and end turn events" do
          expect(allowed_events).to be_one { |e| e.event_type == "attack" }
          expect(allowed_events).to be_one { |e| e.event_type == "fortify" }
          expect(allowed_events).to be_one { |e| e.event_type == "start_turn" }
        end
      end
    end

    context "when the game is won" do
      let(:game_state) { instance_double(GameState, owned_territories: [], won?: true, game: game, territory_owner: player) }

      before do
        expect(GameState).to receive(:new).and_return(game_state)
      end

      it "does not allow any events" do
        expect(allowed_events).to be_empty
      end
    end
  end
end
