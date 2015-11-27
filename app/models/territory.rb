class Territory < ActiveRecord::Base
  belongs_to :game

  validates :game, presence: true

  def connected_territories
    links_to = TerritoryLink.where(from_territory: self).pluck(:to_territory)
    links_from = TerritoryLink.where(to_territory: self).pluck(:from_territory)

    links_to + links_from
  end
end
