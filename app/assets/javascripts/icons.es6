function createIcon(name) {
  return `<svg class="icon-svg">
    <use xlink:href="#icon-${name}" />
  </svg>`;
}

{
  $(".icon").each((index, icon) => {
    let name = /icon\s+([^\s]+)/.exec($(icon).attr("class"))[1];

    $(icon).html(createIcon(name));
  });
}
