class Territory < ActiveRecord::Base
  belongs_to :game
  has_many :actions, dependent: :destroy

  # has_many :from_territory_links, class_name: "TerritoryLink", foreign_key: "from_territory_id"
  # has_many :from_territories, through: :from_territory_links, source: :from_territory
  # has_many :to_territory_links, class_name: "TerritoryLink", foreign_key: "to_territory_id"
  # has_many :to_territories, through: :to_territory_links, source: :to_territory
  #
  # def connected_territories
  #   from_territories + to_territories
  # end

  validates :game, :name, presence: true

  # TODO moar has many through
  def connected_territories
    links_to = TerritoryLink.where(from_territory: self).pluck(:to_territory_id)
    links_from = TerritoryLink.where(to_territory: self).pluck(:from_territory_id)

    Territory.find(links_to + links_from)
  end
end
