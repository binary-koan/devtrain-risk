require "rails_helper"

RSpec.describe SubmitEvent do
  describe "#call" do
    fixtures :games, :territories, :continents

    let(:from_territory) { territories(:territory_top_left) }
    let(:to_territory) { territories(:territory_top_right) }
    let(:units) { nil }
    let(:dice_roller) { DiceRoller.new }

    let(:params) do
      ActionController::Parameters.new(
        from: from_territory.name,
        to: to_territory.name,
        units: units,
        event: {
          event_type: event_type
        }
      )
    end

    let(:game) { games(:game) }
    let(:turn) { BuildTurn.new(game.events).call }
    let(:game_state) { turn.game_state }

    subject(:service) { SubmitEvent.new(game, dice_roller, params) }

    context "with incorrect parameters" do
      let(:params) do
        ActionController::Parameters.new(
          from: "unknown",
          to_territory: "unknown"
        )
      end

      it "raises an ActionController exception" do
        expect { service.call }.to raise_error ActionController::ParameterMissing
      end
    end

    context "when the game is already won" do
      let(:event_type) { "fortify" }

      let(:game_state) { instance_double(GameState, won?: true) }
      let(:turn) { instance_double(Turn, game_state: game_state) }

      it "fails with an error" do
        expect(BuildTurn).to receive(:new).and_return -> { turn }

        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :game_finished
      end
    end

    context "with an attack event" do
      let(:event_type) { "attack" }
      let(:units) { 1 }
      let(:attack_service) { instance_double(PerformAttack, call: true, errors: []) }

      it "calls the PerformAttack service with correct parameters" do
        expect(PerformAttack).to receive(:new).with(
          territory_from:  from_territory,
          territory_to:    to_territory,
          turn:            BuildTurn.new(game.events).call,
          attacking_units: units,
          dice_roller:     dice_roller
        ).and_return(attack_service)

        service.call
      end

      it "succeeds if the PerformAttack service succeeds" do
        expect(PerformAttack).to receive(:new).and_return(attack_service)

        expect(service.call).to eq true
      end

      it "fails and adds errors if the PerformAttack service fails" do
        expect(PerformAttack).to receive(:new).and_return(attack_service)
        expect(attack_service).to receive(:call).and_return(false)
        expect(attack_service).to receive(:errors).and_return([:error])

        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :error
      end
    end

    context "with a fortify event" do
      let(:event_type) { "fortify" }
      let(:units) { 5 }
      let(:fortify_service) { instance_double(PerformFortify, call: true, errors: []) }

      it "calls the PerformFortify service with correct parameters" do
        expect(PerformFortify).to receive(:new).with(
          territory_from:   from_territory,
          territory_to:     to_territory,
          turn:             turn,
          fortifying_units: 5
        ).and_return(fortify_service)

        service.call
      end

      it "succeeds if the PerformFortify service succeeds" do
        expect(PerformFortify).to receive(:new).and_return(fortify_service)

        expect(service.call).to eq true
      end

      it "fails and adds errors if the PerformFortify service fails" do
        expect(PerformFortify).to receive(:new).and_return(fortify_service)
        expect(fortify_service).to receive(:call).and_return(false)
        expect(fortify_service).to receive(:errors).and_return([:error])

        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :error
      end
    end

    context "with a start turn event" do
      let(:event_type) { "start_turn" }
      let(:units) { 5 }
      let(:start_turn_service) { instance_double(StartNextTurn, call: true) }

      it "calls the StartNextTurn service with correct parameters" do
        expect(StartNextTurn).to receive(:new).with(turn).and_return(start_turn_service)

        service.call
      end

      it "succeeds if the StartNextTurn service succeeds" do
        expect(StartNextTurn).to receive(:new).and_return(start_turn_service)

        expect(service.call).to eq true
      end
    end

    context "with a reinforce event" do
      let(:event_type) { "reinforce" }
      let(:units) { 5 }
      let(:reinforce_service) { instance_double(PerformReinforce, call: true, errors: []) }

      it "calls the PerformReinforce service with correct parameters" do
        expect(PerformReinforce).to receive(:new).with(
          territory:          to_territory,
          turn:               turn,
          units_to_reinforce: 5
        ).and_return(reinforce_service)

        service.call
      end

      it "succeeds if the PerformReinforce service succeeds" do
        expect(PerformReinforce).to receive(:new).and_return(reinforce_service)

        expect(service.call).to eq true
      end

      it "fails and adds errors if the PerformReinforce service fails" do
        expect(PerformReinforce).to receive(:new).and_return(reinforce_service)
        expect(reinforce_service).to receive(:call).and_return(false)
        expect(reinforce_service).to receive(:errors).and_return([:error])

        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :error
      end
    end

    context "with an unknown type" do
      let(:event_type) { "nothing" }

      it "causes an error" do
        expect(service.call).to eq false
        expect(service.errors).to contain_exactly :unknown_event_type
      end
    end
  end
end
