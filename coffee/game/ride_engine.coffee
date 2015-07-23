class RideEngine
  constructor: (grid, car, frequency, duration) ->
    @grid = grid
    @car = car
    @frequency = frequency
    @duration = duration
    @generator = null

  _onCarMove: (e) ->
    toRemove = []
    for k, v of @pickupZones
      if v.zone.isNearMe(@car.getCurrentPosition())
        clearTimeout(v.timer)
        v.zone.hide()
        EventBus.get('RideEngine').post(OnPickupEvent.NAME, new OnPickupEvent(v.zone))
        toRemove.push k # Remove from current pickup zones

    for e in toRemove
      delete @pickupZones[e]

  start: () ->
    EventBus.get('Car').register OnCarMoveEvent.NAME, (e) => @_onCarMove(e)
    @pickupZones = {}
    id = 0
    @generator = setInterval(
                              () =>
                                z = new PickupZone(id, @grid, @duration)
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
    clearInterval(@generator)