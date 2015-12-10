FactoryGirl.define do
  factory :action_kill, :class => 'Action::Kill' do
    territory
    units 3
  end
end
