class Player < ActiveRecord::Base
  belongs_to :game
  has_many :events, -> { order(:created_at) }, dependent: :destroy

  validates :game, presence: true
  validates :name, length: { minimum: 1, maximum: 100 }
end
