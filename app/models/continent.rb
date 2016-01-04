class Continent < ActiveRecord::Base
  belongs_to :game

  has_many :territories, dependent: :destroy

  validates :game, :color, presence: true
end
