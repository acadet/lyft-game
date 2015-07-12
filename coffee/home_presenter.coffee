class HomePresenter
  constructor: () ->
    @grid = new Grid('.js-map', 200, 10)

  onStart: () ->
    @grid.render()
