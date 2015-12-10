FactoryGirl.define do
  factory :action_add, :class => 'Action::Add' do
    territory
    units 3
  end
end
