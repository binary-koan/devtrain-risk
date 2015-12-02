require "rails_helper"

RSpec.describe GamesController, type: :controller do
  fixtures :games

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
    before { post :create }

    it "redirects to the game" do
      expect(response).to redirect_to game_path(Game.last)
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

  describe "#event" do
    pending "Test it!"
  end
end
