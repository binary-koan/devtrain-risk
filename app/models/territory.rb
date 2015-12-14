class Territory < ActiveRecord::Base
  belongs_to :continent

  delegate :game, to: :continent

  has_many :to_territory_links, class_name: "TerritoryLink", foreign_key: "to_territory_id"
  has_many :from_territories, through: :to_territory_links, source: :from_territory

  has_many :from_territory_links, class_name: "TerritoryLink", foreign_key: "from_territory_id"
  has_many :to_territories, through: :from_territory_links, source: :to_territory

  def connected_territories
    from_territories + to_territories
  end

  validates :continent, :name, presence: true
end
