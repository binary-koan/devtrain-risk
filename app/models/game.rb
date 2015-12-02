class Game < ActiveRecord::Base
  has_many :players, dependent: :destroy
  has_many :territories, dependent: :destroy
  has_many :events, dependent: :destroy
end
