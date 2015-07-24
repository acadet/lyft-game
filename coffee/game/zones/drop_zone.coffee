class DropZone extends Zone
  constructor: (id, grid, color) ->
    super(id, grid, color)

  getImgExtension: () ->
    'marker'

  postVanished: () ->
    EventBus.get('Zone').post(DropZoneVanishedEvent.NAME, new DropZoneVanishedEvent(@getId()))