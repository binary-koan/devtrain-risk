require "rails_helper"

RSpec.describe GenerateName do
  let(:service) { GenerateName.new }

  describe "#call" do
    it "returns a capitalized name" do
      expect(service.call).to match(/\A[A-Z][a-z]+\z/)
    end
  end
end
