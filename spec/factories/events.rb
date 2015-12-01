FactoryGirl.define do
  factory :event, aliases: [:start_turn_event] do
    game
    player
    event_type "start_turn"

    factory :reinforce_event, traits: [:assigns_units_to_territory] do
      event_type "reinforce"
    end

    factory :takeover_event, traits: [:assigns_units_to_territory] do
      event_type "attack"
    end

    trait(:assigns_units_to_territory) do
      transient { territory(nil) }
      after(:create) do |e, attrs|
        e.actions << create(:action, territory_owner: e.player, territory: attrs.territory)
      end
    end
  end
end
