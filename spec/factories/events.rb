FactoryGirl.define do
  factory :event do
    game
    player
    event_type :end_turn
  end
end
