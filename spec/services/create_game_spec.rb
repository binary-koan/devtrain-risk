require "spec_helper"

RSpec.describe CreateGame do
  describe "#call" do
    let(:service) { CreateGame.new }
    subject(:result) { service.call }
  end
end
