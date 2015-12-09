class Game < ActiveRecord::Base
  has_many :players, dependent: :destroy
  has_many :territories, dependent: :destroy
  has_many :events, -> { order(:created_at) }, through: :players
end
