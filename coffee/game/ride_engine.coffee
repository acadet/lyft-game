class RideEngine
  constructor: (grid, car, frequency, duration) ->
    @grid = grid
    @car = car
    @frequency = frequency
    @duration = duration
    @generator = null

  _onCarMove: () ->
    for k, v of @pickupZones
      if v.zone.isNearMe(@car.getCurrentPosition())
        clearTimeout(v.timer)
        v.zone.hide()

  start: () ->
    @car.watch(() => @_onCarMove())
    @pickupZones = {}
    id = 0
    @generator = setInterval(
                              () =>
                                z = new PickupZone(id, @grid)
                                @pickupZones[id] =
                                  zone: z
                                  timer: setTimeout(
                                                     () =>
                                                       z.hide()
                                                       delete @pickupZones[id]
                                                   ,
                                                     @duration
                                                   )
                                id++
                            ,
                              @frequency
                            )

  stop: () ->
    @car.unwatch()
    clearInterval(@generator)