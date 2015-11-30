FactoryGirl.define do
  factory :event do
    game
    player
    event_type :start_turn
  end
end
