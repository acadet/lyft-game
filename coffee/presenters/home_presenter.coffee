class HomePresenter

  _initCar: () ->
    c = @grid.getSnap().image('imgs/car.png', 0, 0, 20, 20)
    c.addClass('js-car')
    @car = new Car('.js-car', @grid)

  onStart: () ->
    @grid = new Grid('.js-map', 200, 10)
    @grid.render()
    @_initCar()
    @rideEngine = new RideEngine(@grid, @car, 5 * 1000, 10 * 1000)
    EventBus.get('RideEngine').register(PickupEvent.NAME, (z) => @onPickup(z))
    EventBus.get('RideEngine').register(DropEvent.NAME, (z) => @onDrop(z))
    @rideEngine.start()

    @currentRides = {}

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