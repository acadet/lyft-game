class Zone
  @COLORS = ['red', 'blue', 'purple', 'green']
  @SIZE = 30
  @ANIMATION_DURATION_MS =
    @ANIMATION_DELAY_MS = 3 * 1000

  constructor: (id, grid, duration, color) ->
    @id = id
    @grid = grid
    @duration = duration

    # Set marker
    @position = @grid.randomPosition()
    @color = color
    @icon = @grid.getSnap().image(
                                   "imgs/#{@color}-#{@getImgExtension()}.png",
                                   @position.getX() - Zone.SIZE / 2,
                                   @position.getY() - Zone.SIZE / 2,
                                   Zone.SIZE,
                                   Zone.SIZE
                                 )
    @animationTimer = setTimeout(
                                  () => @_animate(),
                                  Zone.ANIMATION_DELAY_MS
                                )

  _animate: () ->
    @animationTimer = null
    @icon.animate({
                    x: @position.getX(),
                    y: @position.getY(),
                    width: 0,
                    height: 0
                  },
                  @duration,
                  null,
                   () =>
                     @hide()
                     @postVanished()
                 )

  getId: () ->
    @id

  getColor: () ->
    @color

  getImgExtension: () ->
    # TO IMPL

  postVanished: () ->
    # TO IMPL

  isNearMe: (point) ->
    PointHelper.compare(point, @position, @grid.getStreetSize() / 2)

  hide: () ->
    clearTimeout(@animationTimer) if @animationTimer?
    @icon.stop()
    @icon.remove()

  @randomColor: () ->
    colorIndex = Math.round(Math.random() * (Zone.COLORS.length - 1))
    return Zone.COLORS[colorIndex]