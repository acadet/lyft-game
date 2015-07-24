class PickupZone extends Zone
  constructor: (id, grid, duration) ->
    super(id, grid, duration, Zone.randomColor())

  getImgExtension: () ->
    'balloon'

  postVanished: () ->
    EventBus.get('Zone').post(PickupZoneVanishedEvent.NAME, new PickupZoneVanishedEvent(@getId()))