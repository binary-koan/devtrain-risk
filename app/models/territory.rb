class Territory < ActiveRecord::Base
  belongs_to :game
  has_many :actions, dependent: :destroy

  validates :game, presence: true

  # TODO moar has many through
  def connected_territories
    links_to = TerritoryLink.where(from_territory: self).pluck(:to_territory_id)
    links_from = TerritoryLink.where(to_territory: self).pluck(:from_territory_id)

    Territory.find(links_to + links_from)
  end
end
