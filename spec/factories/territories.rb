FactoryGirl.define do
  factory :territory, aliases: [:territory_from, :territory_to] do
    continent
    name "Planet X"
    x 0
    y 0
  end
end
