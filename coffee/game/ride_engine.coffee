class RideEngine
  constructor: (grid, period) ->
    @grid = grid
    @period = period
    @generator = null

  start: () ->
    @generator = setInterval(
                              () =>
                                new PickupZone(@grid)
                            ,
                              @period
                            )

  stop: () ->
    clearInterval(@generator)