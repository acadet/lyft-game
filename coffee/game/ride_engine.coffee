class RideEngine
  constructor: (grid, car, frequency, duration) ->
    @grid = grid
    @car = car
    @frequency = frequency
    @duration = duration
    @generator = null

    EventBus.get('Car').register CarMoveEvent.NAME, (e) => @onCarMove(e)
    EventBus.get('Zone').register PickupZoneVanishedEvent.NAME, (e) => @onPickupZoneVanished(e)

  start: () ->
    @pickupZones = {}
    @dropZones = {}
    id = 0
    @generator = setInterval(
                              () =>
                                z = new PickupZone(id, @grid, @duration)
                                @pickupZones[id] = z
                                id++
                            ,
                              @frequency
                            )

  stop: () ->
    clearInterval(@generator)

  onCarMove: (e) ->
    pickupZoneToRemove = []
    dropZoneToRemove = []

    for id, zone of @pickupZones
      if zone.isNearMe(@car.getCurrentPosition())
        zone.hide()
        EventBus.get('RideEngine').post(PickupEvent.NAME, new PickupEvent(zone))
        @dropZones[id] = new DropZone(id, @grid, @duration, zone.getColor())
        pickupZoneToRemove.push id # Remove from current pickup zones

    for id, zone of @dropZones
      if zone.isNearMe(@car.getCurrentPosition())
        zone.hide()
        EventBus.get('RideEngine').post(DropEvent.NAME, new DropEvent(zone))
        dropZoneToRemove.push id

    for e in pickupZoneToRemove
      delete @pickupZones[e]

    for e in dropZoneToRemove
      delete @dropZones[e]

  onPickupZoneVanished: (e) ->
    delete @pickupZones[e.getId()]

  onDropZoneVanished: (e) ->
    delete @dropZones[e.getId()]