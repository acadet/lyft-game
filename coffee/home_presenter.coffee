class HomePresenter
  constructor: () ->

  onStart: () ->
    @grid = new Grid('.js-map', 200, 10)
    @grid.render()
    c = @grid.getSnap().image('imgs/car.png', 0, 0, 20, 20)
    c.addClass('js-car')
    @car = new Car('.js-car', @grid)
    @balloon = new Balloon(@grid, 4000)

    $('.js-map').on 'click', (e) =>
      @car.requestMove(new Point(e.pageX, e.pageY))
