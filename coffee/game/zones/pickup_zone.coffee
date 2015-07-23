class PickupZone extends Zone
  constructor: (id, grid, duration) ->
    super(id, grid, 'balloon', duration)

  postVanished: () ->
    EventBus.get('Zone').post(PickupZoneVanishedEvent.NAME, new PickupZoneVanishedEvent(@getId()))