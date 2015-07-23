class DropZone extends Zone
  constructor: (id, grid, duration, color) ->
    @color = color

    super(id, grid, 'marker', duration)

  getColor: () ->
    @color

  getImgExtension: () ->
    'marker'

  postVanished: () ->
    EventBus.get('Zone').post(DropZoneVanishedEvent.NAME, new DropZoneVanishedEvent(@getId()))