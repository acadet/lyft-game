class RideEngine
  constructor: (grid, frequency, duration) ->
    @grid = grid
    @frequency = frequency
    @duration = duration
    @generator = null

  start: () ->
    @generator = setInterval(
                              () =>
                                new PickupZone(@grid, @duration)
                            ,
                              @frequency
                            )

  stop: () ->
    clearInterval(@generator)