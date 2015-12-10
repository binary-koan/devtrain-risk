class Action::Kill < ActiveRecord::Base
  belongs_to :territory_from
  belongs_to :territory

  validates :territory, :units, presence: true
  validates :units, numericality: { greater_than: 0, only_integer: true }
end
