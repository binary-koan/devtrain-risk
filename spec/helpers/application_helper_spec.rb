require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#icon_sprite" do
    it "returns a SVG document" do
      expect(icon_sprite).to match /\A<svg /
    end
  end

  describe "#icon" do
    it "returns a SVG sprite" do
      expect(icon("attack")).to match /\A<svg/
    end

    it "includes a 'use' element pointing to the correct selector" do
      expect(icon("attack")).to match /<use xlink:href="#icon-attack"/
    end
  end
end
