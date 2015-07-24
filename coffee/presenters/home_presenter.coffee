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

    @rideEngine.start()

  _initScoreManager: () ->
    @scoreManager = new ScoreManager('.js-score')
    @scoreManager.setMissedPickupFare CONFIG.missedPickupFare
    @scoreManager.setMissedDropFare CONFIG.missedDropFare
    @scoreManager.setSuccessfulDropFare CONFIG.successfulDropFare
    @scoreManager.setBonusTip CONFIG.bonusTip
    @scoreManager.setTipSpeedRatio CONFIG.tipSpeedRatio

    EventBus.get('ScoreManager').register(GameOverEvent.NAME, (z) => @onGameOver(z))

  onStart: () ->
    @grid = new Grid('.js-map', 200, 10)
    @grid.render()

    @currentRides = {}

    @_initCar()
    @_initRideEngine()
    @_initScoreManager()

    @userEngine = new UserEngine('.js-user-list', '.js-user-card')

    $('.js-map').on 'click', (e) =>
      @car.requestMove(new Point(e.pageX, e.pageY))

  onPickup: (e) ->
    o =
      zone: e
      user: @userEngine.showRandom()
    @currentRides[e.getZone().getId()] = o

  onDrop: (e) ->
    id = e.getZone().getId()
    o = @currentRides[e.getZone().getId()]
    @userEngine.hide(o.user)
    delete @currentRides[id]

  onGameOver: (e) ->
    console.log('game over')
    @rideEngine.stop()