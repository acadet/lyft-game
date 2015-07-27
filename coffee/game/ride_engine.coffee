# Generates pick up and drop zones
class RideEngine
  @MAX_RIDES = 4

  constructor: (grid, car) ->
    @grid = grid
    @car = car
    @generator = null

    EventBus.get('Car').register CarMoveEvent.NAME, (e) => @onCarMove(e)
    EventBus.get('Zone').register PickupZoneVanishedEvent.NAME, (e) => @onPickupZoneVanished(e)
    EventBus.get('Zone').register DropZoneVanishedEvent.NAME, (e) => @onDropZoneVanished(e)

  _startGenerating: () ->
    @generator = setInterval(
                              () =>
                                z = new PickupZone(@idCounter, @grid)
                                z.setDuration @pickupDuration
                                z.setAnimationDelay @pickupAnimationDelay
                                z.show()
                                @pickupZones[@idCounter] = z
                                @idCounter++
                            ,
                              @pickupFrequency
                            )

  getPickupFrequency: () ->
    @pickupFrequency

  setPickupFrequency: (v) ->
    # Restart generator when updating frequency
    @pickupFrequency = v
    return unless @generator?
    clearInterval(@generator)
    @_startGenerating()

  getPickupDuration: () ->
    @pickupDuration

  setPickupDuration: (v) ->
    @pickupDuration = v

  getPickupAnimationDelay: () ->
    @pickupAnimationDelay

  setPickupAnimationDelay: (v) ->
    @pickupAnimationDelay = v

  getDropDuration: () ->
    @dropDuration

  setDropDuration: (v) ->
    @dropDuration = v

  getDropAnimationDelay: () ->
    @dropAnimationDelay

  setDropAnimationDelay: (v) ->
    @dropAnimationDelay = v

  start: () ->
    @pickupZones = {}
    # Drop zone = start Time + zone
    # Start time is used for the bonus tip ratio
    @dropZones = {}
    @idCounter = 0
    @_startGenerating()

  stop: () ->
    clearInterval(@generator)
    for id, zone of @pickupZones
      zone.hide()
    for id, wrapper of @dropZones
      wrapper.zone.hide()

  onCarMove: (e) ->
    pickupZoneToRemove = []
    dropZoneToRemove = []
    currentRides = Object.keys(@dropZones).length

    # Handle drop zones first, in order to free seats
    for id, wrapper of @dropZones
      if wrapper.zone.isNearMe(@car.getCurrentPosition())
        wrapper.zone.hide()
        speedRatio = (Date.now() - wrapper.startTime) / @dropDuration
        EventBus.get('RideEngine').post(DropEvent.NAME, new DropEvent(wrapper.zone, speedRatio))
        dropZoneToRemove.push id # Remove from current drop zones
        currentRides--

    for id, zone of @pickupZones
      break if currentRides == RideEngine.MAX_RIDES
      if zone.isNearMe(@car.getCurrentPosition())
        zone.hide()
        EventBus.get('RideEngine').post(PickupEvent.NAME, new PickupEvent(zone))
        d = new DropZone(id, @grid, zone.getColor())
        d.setDuration @dropDuration
        d.setAnimationDelay @dropAnimationDelay
        d.show()
        @dropZones[id] =
          startTime: Date.now()
          zone: d
        pickupZoneToRemove.push id # Remove from current pickup zones
        currentRides++

    for e in pickupZoneToRemove
      delete @pickupZones[e]

    for e in dropZoneToRemove
      delete @dropZones[e]

  onPickupZoneVanished: (e) ->
    delete @pickupZones[e.getId()]

  onDropZoneVanished: (e) ->
    delete @dropZones[e.getId()]