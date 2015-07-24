class DropZone extends Zone
  constructor: (id, grid, duration, color) ->
    super(id, grid, duration, color)

  getImgExtension: () ->
    'marker'

  postVanished: () ->
    EventBus.get('Zone').post(DropZoneVanishedEvent.NAME, new DropZoneVanishedEvent(@getId()))