class Event < ActiveRecord::Base
  EVENT_TYPES = %w{reinforce attack fortify start_turn}

  belongs_to :game
  belongs_to :player
  has_many :actions, dependent: :destroy

  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :event_type, :game, :player, presence: true

  def self.reinforce(attrs={})
    new(attrs.merge(event_type: "reinforce"))
  end

  def self.start_turn(attrs={})
    new(attrs.merge(event_type: "start_turn"))
  end

  def self.attack(attrs={})
    new(attrs.merge(event_type: "attack"))
  end

  def self.fortify(attrs={})
    new(attrs.merge(event_type: "fortify"))
  end

  EVENT_TYPES.each do |type|
    define_method((type + "?").to_sym) do
      event_type == type
    end
  end
end
