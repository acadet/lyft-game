class PickupZone extends Zone
  constructor: (id, grid) ->
    super(id, grid, Zone.provideColor())

  getImgExtension: () ->
    'balloon'

  postVanished: () ->
    EventBus.get('Zone').post(PickupZoneVanishedEvent.NAME, new PickupZoneVanishedEvent(@getId()))