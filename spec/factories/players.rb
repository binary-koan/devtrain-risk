FactoryGirl.define do
  factory :player, aliases: [:territory_owner] do
    game
    name "Player 1"
  end
end
