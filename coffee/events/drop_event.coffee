class DropEvent
  @NAME = 'DropEvent'

  constructor: (zone, speedRatio) ->
    @zone = zone
    @speedRatio = speedRatio

  getZone: () ->
    @zone

  getSpeedRatio: () ->
    @speedRatio