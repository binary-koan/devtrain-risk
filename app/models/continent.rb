class Continent < ActiveRecord::Base
  belongs_to :game

  has_many :territories, dependent: :destroy

  validates :game, :color, presence: true
  #validates :color, format: { with: /\A#([0-9|A-Z|a-z]{6}|[0-9|A-Z|a-z]{3})\z/ }
end
