class Event < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :actions, dependent: :destroy

  validates :event_type, inclusion: { in: %w{reinforce attack fortify start_turn} }
  validates :event_type, :game, :player, presence: true

  def self.reinforce(attrs={})
    new(attrs.merge(event_type: "reinforce"))
  end
end
