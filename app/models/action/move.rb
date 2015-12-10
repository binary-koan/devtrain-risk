class Action::Move < ActiveRecord::Base
  belongs_to :territory_from, class_name: "Territory"
  belongs_to :territory_to, class_name: "Territory"

  validates :territory_from, :territory_to, :units, presence: true
  validates :units, numericality: { greater_than: 0, only_integer: true }
end
