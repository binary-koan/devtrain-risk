class Event < ActiveRecord::Base
  EVENT_TYPES = %w{reinforce attack fortify start_turn}

  EVENT_TYPES.each do |event_type|
    scope event_type, -> { where(event_type: event_type) }

    define_method(event_type + "?") { self.event_type == event_type }
  end

  belongs_to :player
  belongs_to :action, polymorphic: true

  delegate :game, to: :player

  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :event_type, :player, presence: true
end
