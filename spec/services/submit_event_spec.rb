require "rails_helper"

RSpec.describe SubmitEvent do
  describe "#call" do
    fixtures :games, :territories

    let(:from_index) { 0 }
    let(:to_index) { 1 }
    let(:units) { nil }

    let(:params) do
      {
        from: from_index,
        to: to_index,
        units: units,
        event: {
          event_type: event_type
        }
      }
    end

    let(:game) { games(:game) }
    let(:game_state) { BuildGameState.new(game, game.events).call }

    subject(:service) { SubmitEvent.new(game, params) }

    context "with an attack event" do
      let(:event_type) { "attack" }
      let(:attack_service) { instance_double(PerformAttack, call: true, errors: []) }

      it "calls the PerformAttack service with correct parameters" do
        expect(PerformAttack).to receive(:new).with(
          territory_from: game.territories[from_index],
          territory_to: game.territories[to_index],
          game_state: BuildGameState.new(game, game.events).call
        ).and_return(attack_service)

        service.call
      end

      it "succeeds if the PerformAttack service succeeds" do
        expect(PerformAttack).to receive(:new).and_return(attack_service)

        expect(service.call).to eq true
      end

      it "fails if the PerformAttack service fails" do
        expect(PerformAttack).to receive(:new).and_return(attack_service)
        expect(attack_service).to receive(:call).and_return(false)

        expect(service.call).to eq false
      end

      it "has the same errors as the service if it fails" do
        expect(PerformAttack).to receive(:new).and_return(attack_service)
        expect(attack_service).to receive(:call).and_return(false)
        expect(attack_service).to receive(:errors).and_return([:error])

        service.call
        expect(service.errors).to eq [:error]
      end
    end

    context "with a fortify event" do
      let(:event_type) { "fortify" }
      let(:units) { 5 }
      let(:fortify_service) { instance_double(PerformFortify, call: true, errors: []) }

      it "calls the PerformFortify service with correct parameters" do
        expect(PerformFortify).to receive(:new).with(
          territory_from: game.territories[from_index],
          territory_to: game.territories[to_index],
          game_state: game_state,
          fortifying_units: 5
        ).and_return(fortify_service)

        service.call
      end

      it "succeeds if the PerformFortify service succeeds" do
        expect(PerformFortify).to receive(:new).and_return(fortify_service)

        expect(service.call).to eq true
      end

      it "fails if the PerformFortify service fails" do
        expect(PerformFortify).to receive(:new).and_return(fortify_service)
        expect(fortify_service).to receive(:call).and_return(false)

        expect(service.call).to eq false
      end

      it "has the same errors as the service if it fails" do
        expect(PerformFortify).to receive(:new).and_return(fortify_service)
        expect(fortify_service).to receive(:call).and_return(false)
        expect(fortify_service).to receive(:errors).and_return([:error])

        service.call
        expect(service.errors).to eq [:error]
      end
    end

    context "with a start (end) turn event" do
      let(:event_type) { "start_turn" }
      let(:units) { 5 }
      let(:end_turn_service) { instance_double(EndTurn, call: true) }

      it "calls the EndTurn service with correct parameters" do
        expect(EndTurn).to receive(:new).with(game_state).and_return(end_turn_service)

        service.call
      end

      it "succeeds if the EndTurn service succeeds" do
        expect(EndTurn).to receive(:new).and_return(end_turn_service)

        expect(service.call).to eq true
      end
    end

    context "with a fortify event" do
      let(:event_type) { "reinforce" }
      let(:units) { 5 }
      let(:reinforce_service) { instance_double(PerformReinforce, call: true, errors: []) }

      it "calls the PerformReinforce service with correct parameters" do
        expect(PerformReinforce).to receive(:new).with(
          territory: game.territories[to_index],
          game_state: game_state,
          units_to_reinforce: 5
        ).and_return(reinforce_service)

        service.call
      end

      it "succeeds if the PerformReinforce service succeeds" do
        expect(PerformReinforce).to receive(:new).and_return(reinforce_service)

        expect(service.call).to eq true
      end

      it "fails if the PerformReinforce service fails" do
        expect(PerformReinforce).to receive(:new).and_return(reinforce_service)
        expect(reinforce_service).to receive(:call).and_return(false)

        expect(service.call).to eq false
      end

      it "has the same errors as the service if it fails" do
        expect(PerformReinforce).to receive(:new).and_return(reinforce_service)
        expect(reinforce_service).to receive(:call).and_return(false)
        expect(reinforce_service).to receive(:errors).and_return([:error])

        service.call
        expect(service.errors).to eq [:error]
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
