require "rails_helper"

RSpec.describe PerformAttack do
  let(:territory_from) { instance_double(Territory) }
  let(:territory_to) { instance_double(Territory) }
  let(:game) { instance_double(Game) }
  let(:game_state) { instance_double(GameState) }

  let(:attacking_units) { 3 }
  let(:dice_roller) { DiceRoller.new }

  let(:service_args) do
    {
      game_state:      game_state,
      dice_roller:     dice_roller,
      territory_from:  territory_from,
      territory_to:    territory_to,
      attacking_units: attacking_units
    }
  end

  let(:service) do
    PerformAttack.new(**service_args)
  end

  let(:attack_events) { [instance_double(Event)] }
  let(:attack_creator) { -> { attack_events } }
  let(:attack_validator) { instance_double(PerformAttack::ValidateAttack) }

  describe "#call" do
    before do
      expect(PerformAttack::ValidateAttack).to receive(:new).with(service_args).and_return(attack_validator)
      expect(PerformAttack::CreateAttack).to receive(:new).with(service_args).and_return(attack_creator)
    end

    context "when validation fails" do
      before { allow(attack_validator).to receive(:errors).and_return([:error]) }

      it "fails with the errors of the validator" do
        expect(attack_validator).to receive(:call).and_return(false)
        expect(attack_creator).not_to receive(:call)

        expect(service.call).to eq false
        expect(service.errors).to eq attack_validator.errors
      end
    end

    context "when validation succeeds" do
      before do
        expect(attack_validator).to receive(:call).and_return(true)
      end

      it "returns true" do
        expect(service.call).to eq true
      end

      it "allows access to the event returned by the creation service" do
        service.call
        expect(service.attack_events).to eq attack_events
      end
    end
  end
end
