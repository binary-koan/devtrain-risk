class Game < ActiveRecord::Base
  has_many :players, dependent: :destroy
  has_many :events, -> { order(:created_at) }, through: :players
  has_many :continents, dependent: :destroy
  has_many :territories, -> { order(:id) },  through: :continents
end
