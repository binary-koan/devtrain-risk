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

      after(:create) do |e, attrs|
        e.actions << create(:action,
          action_type: :add,
          territory_owner: e.player,
          territory: attrs.territory,
          units_difference: attrs.units
        )
      end
    end

    factory :fortify_event do
      event_type "fortify"

      transient do
        territory_from nil
        territory_to nil
        units 2
      end

      after(:create) do |e, attrs|
        e.actions << create(:action,
          action_type: :move_from,
          territory_owner: e.player,
          territory: attrs.territory_from,
          units_difference: -attrs.units
        )

        e.actions << create(:action,
          action_type: :move_to,
          territory_owner: e.player,
          territory: attrs.territory_to,
          units_difference: attrs.units
        )
      end
    end

    factory :attack_event do
      event_type "attack"

      transient do
        territory nil
        units_killed 2
      end

      after(:create) do |e, attrs|
        e.actions << create(:action,
          action_type: :kill,
          territory_owner: e.player,
          territory: attrs.territory,
          units_difference: -attrs.units_killed
        )
      end
    end

    factory :takeover_event do
      event_type "attack"

      transient do
        territory_from nil
        territory_taken nil
        units_killed 2
        units_moved 2
      end

      after(:create) do |e, attrs|
        e.actions << create(:action,
          action_type: :kill,
          territory_owner: e.player,
          territory: attrs.territory_taken,
          units_difference: -attrs.units_killed
        )

        e.actions << create(:action,
          action_type: :move_to,
          territory_owner: e.player,
          territory: attrs.territory_taken,
          units_difference: attrs.units_moved
        )

        e.actions << create(:action,
          action_type: :move_from,
          territory_owner: e.player,
          territory: attrs.territory_from,
          units_difference: -attrs.units_moved
        )
      end
    end
  end
end
