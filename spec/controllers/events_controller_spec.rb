require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  fixtures :games

  describe "#create" do
    let(:call_result) { true }
    let(:submit_event) { instance_double(SubmitEvent, call: call_result) }

    it "redirects to the game" do
      expect(SubmitEvent).to receive(:new).and_return submit_event
      post :create, game_id: games(:game).id
      expect(response).to redirect_to game_path(Game.last)
    end

    context "the submit returns an error" do
      let(:call_result) { false }

      it "adds an error to the flash" do
        expect(SubmitEvent).to receive(:new).and_return submit_event
        expect(submit_event).to receive(:errors).and_return [:unknown_event_type]
        post :create, game_id: games(:game).id
        expect(flash.alert).to eq [:unknown_event_type]
      end
    end
  end
end
