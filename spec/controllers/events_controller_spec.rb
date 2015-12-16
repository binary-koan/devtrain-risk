require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  fixtures :games

  describe "#create" do
    let(:call_result) { true }
    let(:submit_event) { instance_double(SubmitEvent, call: call_result) }

    it "redirects to the game" do
      expect(SubmitEvent).to receive(:new).and_return submit_event
      post :create, game_id: games(:game).id
      expect(response).to redirect_to game_path(games(:game))
    end

    context "the submit returns an error" do
      let(:call_result) { false }

      it "returns a JSON error response" do
        expect(SubmitEvent).to receive(:new).and_return submit_event
        expect(submit_event).to receive(:errors).and_return [:unknown_event_type]
        post :create, game_id: games(:game).id
        expect(response.body).to eq ({ errors: ["That's not a valid event type"] }).to_json
      end
    end
  end
end
