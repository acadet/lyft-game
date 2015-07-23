class Zone
  @COLORS = ['red', 'blue', 'purple', 'green']
  @SIZE = 30
  @ANIMATION_DURATION_MS = 500
  @ANIMATION_DELAY_MS = 5 * 1000

  constructor: (grid, countdownDelay, imgExtension) ->
    @grid = grid
    @position = grid.randomPosition()
    colorIndex = Math.round(Math.random() * (Zone.COLORS.length - 1))
    @icon = @grid.getSnap().image(
                                   "imgs/#{Zone.COLORS[colorIndex]}-#{imgExtension}.png",
                                   @position.getX() - Zone.SIZE / 2,
                                   @position.getY() - Zone.SIZE / 2,
                                   Zone.SIZE,
                                   Zone.SIZE
                                 )
    @animationTimer = setInterval(
                                   () => @_animate(),
                                   Zone.ANIMATION_DELAY_MS
                                 )
    @countdown = setTimeout(
                             () => @hide(),
                             countdownDelay
                           )

  _animate: () ->
    x = @icon.attr('x')
    y = @icon.attr('y')
    size = Zone.SIZE * 3 / 4
    @icon.animate({
                    x: @position.getX() - size / 2
                    y: @position.getY() - size / 2
                    width: size,
                    height: size
                  },
                  Zone.ANIMATION_DURATION_MS
                 )
    setTimeout(
                () =>
                  @icon.animate(
                                 {
                                   x: x,
                                   y: y,
                                   width: Zone.SIZE,
                                   height: Zone.SIZE
                                 },
                                 Zone.ANIMATION_DURATION_MS
                               )
              ,
                Zone.ANIMATION_DURATION_MS
              )

  isNearMe: (point) ->
    PointHelper.compare(point, @position, @grid.getStreetSize() / 2)

  hide: () ->
    clearInterval(@animationTimer)
    @icon.remove()