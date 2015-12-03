FactoryGirl.define do
  factory :event, aliases: [:start_turn_event] do
    game
    player
    event_type "start_turn"

    factory :mock_event, traits: [:assigns_units_to_territory] do
      event_type "reinforce"
    end

    factory :reinforce_event, traits: [:assigns_units_to_territory] do
      event_type "reinforce"
      units_difference Reinforcement.new.remaining_reinforcements
    end

    factory :takeover_event, traits: [:assigns_units_to_territory] do
      event_type "attack"
    end

    trait(:assigns_units_to_territory) do
      transient do
        territory(nil)
        units_difference(10)
      end

      after(:create) do |e, attrs|
        e.actions << create(
          :action,
          territory_owner: e.player,
          territory: attrs.territory,
          units_difference: attrs.units_difference
        )
      end
    end
  end
end
