class Action < ActiveRecord::Base
  belongs_to :event
  belongs_to :territory
  belongs_to :territory_owner, class_name: "Player"

  enum action_type: %i{add kill move_from move_to}

  validates :event, :territory, :territory_owner, :action_type, presence: true
  validates :units_difference, exclusion: { in: [0], message: "can't be zero" }
end
