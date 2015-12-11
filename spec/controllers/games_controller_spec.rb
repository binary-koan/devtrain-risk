require "rails_helper"

RSpec.describe GamesController, type: :controller do
  fixtures :games, :events
  let(:create_game_service) { instance_double(CreateGame) }

  describe "#new" do
    before { get :new }

    it "is successful" do
      expect(response).to have_http_status :success
    end

    it "renders the 'new' template" do
      expect(response).to render_template :new
    end
  end

  describe "#create" do
    context "with a valid map name" do
      before { post :create, map_name: "default" }

      it "redirects to the game" do
        expect(response).to redirect_to game_path(Game.last)
      end
    end

    context "with an invalid map name" do
      before do
        @request.env['HTTP_REFERER'] = 'https://test.host/games/new'
        post :create, map_name: "bad_map"
      end

      it "adds adds the errors to the flash" do
        expect(flash.alert).to eq [:not_valid_map_name]
      end

      it "redirects back to the new page" do
        expect(response).to redirect_to :back
      end
    end
  end

  describe "#show" do
    before { get :show, id: games(:game).id }

    it "is successful" do
      expect(response).to have_http_status :success
    end

    it "renders the 'show' template" do
      expect(response).to render_template :show
    end
  end
end
