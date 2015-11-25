class Game < ActiveRecord::Base
  has_many :players
  has_many :territories
  has_many :events
end
