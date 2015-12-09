class Action < ActiveRecord::Base
  belongs_to :event
  belongs_to :territory
  belongs_to :territory_owner, class_name: "Player"

  validates :event, :territory, :territory_owner, presence: true
  validates :units_difference, exclusion: { in: [0], message: "can't be zero" }
end
