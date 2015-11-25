class Change < ActiveRecord::Base
  belongs_to :event
  belongs_to :territory
  belongs_to :territory_owner, class_name: "Player"

  validates :event, presence: true
  validates :player, presence: true

  validates :units_difference, exclusion: { in: [0] }
end
