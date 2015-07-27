class PickupEvent
  @NAME = 'PickupEvent'

  constructor: (zone) ->
    @zone = zone

  # Returns pick up zone
  getZone: () ->
    @zone
