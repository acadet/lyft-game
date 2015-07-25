class HomePresenter

  _initCar: () ->
    c = @grid.getSnap().image('imgs/car.png', 0, 0, 20, 20)
    c.addClass('js-car')
    @car = new Car('.js-car', @grid, CONFIG.carSpeed)

  _initRideEngine: () ->
    @rideEngine = new RideEngine(@grid, @car)
    @rideEngine.setPickupFrequency CONFIG.pickupFrequency
    @rideEngine.setPickupDuration CONFIG.pickupDuration
    @rideEngine.setPickupAnimationDelay CONFIG.pickupAnimationDelay
    @rideEngine.setDropDuration CONFIG.dropDuration
    @rideEngine.setDropAnimationDelay CONFIG.dropAnimationDelay

    EventBus.get('RideEngine').register(PickupEvent.NAME, (z) => @onPickup(z))
    EventBus.get('RideEngine').register(DropEvent.NAME, (z) => @onDrop(z))
    EventBus.get('Zone').register DropZoneVanishedEvent.NAME, (z) => @onMissedDrop(z)
    EventBus.getDefault().register(
                                    OnStartEvent.NAME,
                                    () =>
                                      @startTime = Date.now()
                                      @rideEngine.start()
                                  )

  _initScoreManager: () ->
    @scoreManager = new ScoreManager('.js-score')
    @scoreManager.setMissedPickupFare CONFIG.missedPickupFare
    @scoreManager.setMissedDropFare CONFIG.missedDropFare
    @scoreManager.setSuccessfulDropFare CONFIG.successfulDropFare
    @scoreManager.setBonusTip CONFIG.bonusTip
    @scoreManager.setTipSpeedRatio CONFIG.tipSpeedRatio

    EventBus.get('ScoreManager').register(GameOverEvent.NAME, (z) => @onGameOver(z))

  onStart: () ->
    @grid = new Grid('.js-map', CONFIG.blockSize, CONFIG.streetSize)
    @grid.render()

    @currentRides = {}

    @_initCar()
    @_initRideEngine()
    @_initScoreManager()

    @userEngine = new UserEngine('.js-user-list', '.js-user-card')

    $('.js-map').on 'click', (e) =>
      x = e.pageX - @grid.getSource().offset().left
      y = e.pageY - @grid.getSource().offset().top
      @car.requestMove(new Point(x, y))

    @pickupSound = new Audio('sounds/car.mp3')
    @dropSound = new Audio('sounds/cash.mp3')

    @popupManager = new PopupManager()
    @popupManager.showStart()

  onPickup: (e) ->
    o =
      zone: e.getZone()
      user: @userEngine.showRandom(e.getZone().getColor())
    @currentRides[e.getZone().getId()] = o
    @pickupSound.play()

  onMissedDrop: (e) ->
    o = @currentRides[e.getId()]
    @userEngine.hide(o.user)
    delete @currentRides[e.getId()]

  onDrop: (e) ->
    id = e.getZone().getId()
    o = @currentRides[e.getZone().getId()]
    @userEngine.hide(o.user)
    delete @currentRides[id]
    @dropSound.play()

  onGameOver: (e) ->
    return if @isOver
    @isOver = true
    @rideEngine.stop()
    @popupManager.showEnding(Date.now() - @startTime)
