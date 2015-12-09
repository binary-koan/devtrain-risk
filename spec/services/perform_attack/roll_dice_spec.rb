require "rails_helper"

RSpec.describe PerformAttack::RollDice do
  let(:service) { PerformAttack::RollDice.new(attacker_count, defender_count) }

  describe "#call" do
    before { expect(service).to receive(:rand).and_return(*(attacker_rolls + defender_rolls)) }

    subject { service.call }

    context "with the same number of attackers and defenders" do
      let(:attacker_count) { 2 }
      let(:defender_count) { 2 }
      let(:attacker_rolls) { [2, 4] }
      let(:defender_rolls) { [5, 3] }

      it { is_expected.to eq [[4, 5], [2, 3]] }
    end

    context "with more attackers than defenders" do
      let(:attacker_count) { 3 }
      let(:defender_count) { 2 }
      let(:attacker_rolls) { [2, 1, 5] }
      let(:defender_rolls) { [3, 2] }

      it { is_expected.to eq [[5, 3], [2, 2]] }
    end

    context "with more defenders than attackers" do
      let(:attacker_count) { 1 }
      let(:defender_count) { 2 }
      let(:attacker_rolls) { [3] }
      let(:defender_rolls) { [6, 1] }

      it { is_expected.to eq [[3, 6]] }
    end
  end
end
