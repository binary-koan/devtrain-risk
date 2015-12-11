FactoryGirl.define do
  factory :action_kill, :class => 'Action::Kill' do
    territory_from
    territory
    units 3
  end
end
