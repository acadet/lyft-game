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
    EventBus.get('RideEngine').register(OnPickupEvent.NAME, (z) => @onPickup(z))
    @rideEngine.watch (z) => @onPickup(z)
    @rideEngine.start()

    @userEngine = new UserEngine('.js-user-list', '.js-user-card')

    $('.js-map').on 'click', (e) =>
      @car.requestMove(new Point(e.pageX, e.pageY))

  onPickup: (e) ->
    @userEngine.showRandom()