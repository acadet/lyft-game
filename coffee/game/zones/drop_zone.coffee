class DropZone extends Zone
  constructor: (id, grid, color) ->
    super(id, grid, color)

  getImgExtension: () ->
    'marker'

  postVanished: () ->
    EventBus.get('Zone').post(DropZoneVanishedEvent.NAME, new DropZoneVanishedEvent(@getId()))

  hide: () ->
    super
    # Free color
    Zone.colorInUse--
    for e in Zone.colors
      if e.label is @getColor()
        e.inUse = false
        break