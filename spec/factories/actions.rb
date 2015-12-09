FactoryGirl.define do
  factory :action do
    event
    territory
    territory_owner
    action_type :add
    units_difference 10
  end
end
