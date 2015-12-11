FactoryGirl.define do
  factory :event, aliases: [:start_turn_event] do
    player
    event_type "start_turn"

    factory :reinforce_event do
      event_type "reinforce"

      transient do
        territory nil
        units Reinforcement::MINIMUM_UNIT_COUNT
      end

      after(:build) do |e, attrs|
        e.action = build(:action_add,
          territory: attrs.territory,
          units: attrs.units
        )
      end

      after(:create) { |e| e.action.save! }
    end

    factory :fortify_event do
      event_type "fortify"

      transient do
        territory_from nil
        territory_to nil
        units 2
      end

      after(:build) do |e, attrs|
        e.action = build(:action_move,
          territory_from: attrs.territory_from,
          territory_to: attrs.territory_to,
          units: attrs.units
        )
      end

      after(:create) { |e| e.action.save! }
    end

    factory :attack_event do
      event_type "attack"

      transient do
        territory nil
        territory_from nil
        units 2
      end

      after(:build) do |e, attrs|
        e.action = build(:action_kill,
          territory: attrs.territory,
          territory_from: attrs.territory_from || create(:territory),
          units: attrs.units
        )
      end

      after(:create) { |e| e.action.save! }
    end
  end
end
