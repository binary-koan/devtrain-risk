FactoryGirl.define do
  factory :player, aliases: [:territory_owner] do
    game
    name "Unnamed player"
  end
end
