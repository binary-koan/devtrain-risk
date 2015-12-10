FactoryGirl.define do
  factory :action_move, :class => 'Action::Move' do
    territory_from
    territory_to
    units 3
  end
end
