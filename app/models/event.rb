class Event < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :actions

  validates :event_type, inclusion: { in: %w{reinforce attack fortify start_turn} }
  validates :event_type, presence: true
  validates :game, presence: true
  validates :player, presence: true
end
