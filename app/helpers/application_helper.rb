module ApplicationHelper
  def icon_sprite
    File.open("app/assets/images/icons.svg", "rb") do |file|
      raw file.read
    end
  end

  def icon(name)
    content_tag("svg", content_tag("use", "", "xlink:href" => "#icon-#{name}"),
      class: "icon #{name}")
  end
end
