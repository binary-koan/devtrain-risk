class TerritoryLink < ActiveRecord::Base
  belongs_to :from_territory, class_name: "Territory"
  belongs_to :to_territory, class_name: "Territory"
end
