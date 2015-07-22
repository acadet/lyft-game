class HomePresenter
  constructor: () ->

  onStart: () ->
    @grid = new Grid('.js-map', 200, 10)
    @grid.render()
    @car = new Car('.js-car', @grid)

    $('.js-map').on 'click', (e) =>
      @car.requestMove(new Point(e.pageX, e.pageY))
