# Main class. Creates the different game components and
# acts as a mediator.
class HomePresenter

  _initCar: () ->
    c = @grid.getSnap().image('imgs/car.png', 0, 0, 20, 20)
    c.addClass('js-car')

    # Increase speed depending on the grid's size
    speed = CONFIG.carSpeed
    ratio = Math.max(@grid.getBlockWidth(), @grid.getBlockHeight()) / 800
    speed *= ratio if ratio > 1

    @car = new Car('.js-car', @grid, speed)

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
                                    StartEvent.NAME,
                                    () =>
                                      @startTime = Date.now()
                                      @rideEngine.start()
                                  )

  _initScoreManager: () ->
    @isOver = false
    @scoreManager = new ScoreManager('.js-score')
    @scoreManager.setMissedPickupFare CONFIG.missedPickupFare
    @scoreManager.setMissedDropFare CONFIG.missedDropFare
    @scoreManager.setSuccessfulDropFare CONFIG.successfulDropFare
    @scoreManager.setBonusTip CONFIG.bonusTip
    @scoreManager.setTipSpeedRatio CONFIG.tipSpeedRatio

    EventBus.get('ScoreManager').register(GameOverEvent.NAME, (z) => @onGameOver(z))
    EventBus.get('ScoreManager').register(IncreaseDifficultyEvent.NAME, (z) => @onIncreasingDifficulty(z))

  onStart: () ->
    if BrowserHelper.isFirefox()
      # SVG tag does not recognize relative sizes using Firefox
      $('.js-map').css
        width: $('.js-map').parent().width()
        height: $('.js-map').parent().height()
    @grid = new Grid('.js-map', CONFIG.blockNumber, CONFIG.streetSize)
    @grid.render()

    # Ride = zone + rider
    @currentRides = {}

    @_initCar()
    @_initRideEngine()
    @_initScoreManager()

    @userEngine = new UserEngine('.js-user-list', '.js-user-card')

    $('.js-map').on 'click', (e) =>
      # User is moving the car
      x = e.pageX - @grid.getSource().offset().left - parseInt(@grid.getSource().css('padding-left'))
      y = e.pageY - @grid.getSource().offset().top - parseInt(@grid.getSource().css('padding-top'))
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
    @popupManager.showEnding(Date.now() - @startTime, @scoreManager.getMaxScore())

  onIncreasingDifficulty: (e) ->
    if @rideEngine.getPickupFrequency() > 1
      @rideEngine.setPickupFrequency(@rideEngine.getPickupFrequency() / 2)

    # Do not decrease pick up and drop durations more than 3s
    if @rideEngine.getPickupDuration() > 3
      @rideEngine.setPickupDuration(@rideEngine.getPickupDuration() - 1)
      if @rideEngine.getPickupDuration() <= @rideEngine.getPickupAnimationDelay()
        @rideEngine.setPickupAnimationDelay(0)

    if @rideEngine.getDropDuration() > 3
      @rideEngine.setDropDuration(@rideEngine.getDropDuration() - 1)
      if @rideEngine.getDropDuration() <= @rideEngine.getDropAnimationDelay
        @rideEngine.setDropAnimationDelay(0)

    # Increase fares
    @scoreManager.setMissedPickupFare(Math.round(@scoreManager.getMissedPickupFare() * 2))
    @scoreManager.setMissedDropFare(Math.round(@scoreManager.getMissedDropFare() * 2))
    @scoreManager.setSuccessfulDropFare(Math.round(@scoreManager.getSuccessfulDropFare() * 2))
    @scoreManager.setBonusTip(Math.round(@scoreManager.getBonusTip() * 2))