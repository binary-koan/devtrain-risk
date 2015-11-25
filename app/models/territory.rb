class Territory < ActiveRecord::Base
  belongs_to :game

  validates :game, presence: true

  def connected_territories
    #TODO some stuff
  end
end
