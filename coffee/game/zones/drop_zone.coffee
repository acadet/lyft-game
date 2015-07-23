class DropZone extends Zone
  constructor: (id, grid, duration, color) ->
    super(id, grid, 'marker', duration)

    @color = color

  getColor: () ->
    @color

  getImgExtension: () ->
    'marker'

  postVanished: () ->
    EventBus.get('Zone').post(DropZoneVanishedEvent.NAME, new DropZoneVanishedEvent(@getId()))