class Action::Kill < ActiveRecord::Base
  belongs_to :territory_from, class_name: "Territory"
  belongs_to :territory

  validates :territory_from, :territory, :units, presence: true
  validates :units, numericality: { greater_than: 0, only_integer: true }
end
