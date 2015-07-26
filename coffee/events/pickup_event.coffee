class PickupEvent
  @NAME = 'PickupEvent'

  constructor: (zone) ->
    @zone = zone

  getZone: () ->
    @zone
