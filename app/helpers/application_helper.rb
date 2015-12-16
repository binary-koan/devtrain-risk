module ApplicationHelper
  def icon_sprite
    raw Rails.root.join("app/assets/images/icons.svg").read
  end

  def icon(name)
    content_tag("svg", class: "icon #{name}") do
      content_tag("use", "", "xlink:href" => "#icon-#{name}")
    end
  end
end
