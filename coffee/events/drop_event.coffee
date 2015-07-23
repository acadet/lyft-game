class DropEvent
  @NAME = 'DropEvent'

  constructor: (zone) ->
    @zone = zone

  getZone: () ->
    @zone