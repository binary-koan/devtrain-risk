class Event < ActiveRecord::Base
  enum type: %i{reinforce attack fortify}

  belongs_to :player

  validates :type, presence: true
  validates :player, presence: true
end
