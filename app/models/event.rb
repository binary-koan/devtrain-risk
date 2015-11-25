class Event < ActiveRecord::Base
  enum event_type: %i{reinforce attack fortify end_turn}

  belongs_to :player
  has_many :actions

  validates :event_type, presence: true
  validates :player, presence: true
end
