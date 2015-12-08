FactoryGirl.define do
  factory :event, aliases: [:start_turn_event, :mock_event] do
    player
    event_type "start_turn"

    factory :reinforce_event, traits: [:assigns_units_to_territory] do
      event_type "reinforce"
      units_difference Reinforcement::MINIMUM_UNIT_COUNT
    end

    factory :attack_event, aliases: [:takeover_event], traits: [:assigns_units_to_territory] do
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
