class RideEngine
  constructor: (grid, car, frequency, duration) ->
    @grid = grid
    @car = car
    @frequency = frequency
    @duration = duration
    @generator = null

    EventBus.get('Car').register CarMoveEvent.NAME, (e) => @onCarMove(e)
    EventBus.get('Zone').register ZoneVanishedEvent.NAME, (e) => @onZoneVanished(e)

  start: () ->
    @pickupZones = {}
    id = 0
    @generator = setInterval(
                              () =>
                                z = new PickupZone(id, @grid, @duration)
                                @pickupZones[id] =
                                  zone: z
                                id++
                            ,
                              @frequency
                            )

  stop: () ->
    clearInterval(@generator)


  onCarMove: (e) ->
    toRemove = []
    for k, v of @pickupZones
      if v.zone.isNearMe(@car.getCurrentPosition())
        v.zone.hide()
        EventBus.get('RideEngine').post(PickupEvent.NAME, new PickupEvent(v.zone))
        toRemove.push k # Remove from current pickup zones

    for e in toRemove
      delete @pickupZones[e]

  onZoneVanished: (e) ->
    delete @pickupZones[e.getId()]