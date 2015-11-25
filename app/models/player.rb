class Player < ActiveRecord::Base
  belongs_to :game

  validates :game, presence: true
  validates :name, length: { minimum: 1, maximum: 100 }
end
