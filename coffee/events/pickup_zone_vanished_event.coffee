class PickupZoneVanishedEvent
  @NAME = 'PickupZoneVanishedEvent'

  constructor: (id) ->
    @id = id

  getId: () ->
    @id