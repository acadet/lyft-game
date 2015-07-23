class Zone
  @COLORS = ['red', 'blue', 'purple', 'green']
  @SIZE = 30
  @ANIMATION_DURATION_MS =
    @ANIMATION_DELAY_MS = 3 * 1000

  constructor: (id, grid, duration) ->
    @id = id
    @grid = grid
    @duration = duration

    # Set marker
    @position = @grid.randomPosition()
    @icon = @grid.getSnap().image(
                                   "imgs/#{@getColor()}-#{@getImgExtension()}.png",
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
    @icon.animate({
                    x: @position.getX(),
                    y: @position.getY(),
                    width: 0,
                    height: 0
                  },
                  @duration,
                  null,
                   () =>
                     @postVanished()
                     @hide()
                 )

  getId: () ->
    @id

  getColor: () ->
    # TO IMPL

  getImgExtension: () ->
    # TO IMPL

  postVanished: () ->
    # TO IMPL

  isNearMe: (point) ->
    PointHelper.compare(point, @position, @grid.getStreetSize() / 2)

  hide: () ->
    clearTimeout(@animationTimer)
    @icon.stop()
    @icon.remove()