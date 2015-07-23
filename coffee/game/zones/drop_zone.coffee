class DropZone extends Zone
  constructor: (id, grid, duration) ->
    super(id, grid, 'marker', duration)

  postVanished: () ->
    EventBus.get('Zone').post(DropZoneVanishedEvent.NAME, new DropZoneVanishedEvent(@getId()))