class Zone
  @COLORS = ['red', 'blue', 'purple', 'green']
  @SIZE = 30
  @ANIMATION_DURATION_MS =
    @ANIMATION_DELAY_MS = 3 * 1000

  constructor: (id, grid, imgExtension, duration) ->
    @id = id
    @grid = grid
    @duration = duration

    # Set marker
    @position = @grid.randomPosition()
    colorIndex = Math.round(Math.random() * (Zone.COLORS.length - 1))
    @icon = @grid.getSnap().image(
                                   "imgs/#{Zone.COLORS[colorIndex]}-#{imgExtension}.png",
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
                     EventBus.get('Zone').post(ZoneVanishedEvent.NAME, ZoneVanishedEvent(@id))
                     @hide()
                 )

  getId: () ->
    @id

  isNearMe: (point) ->
    PointHelper.compare(point, @position, @grid.getStreetSize() / 2)

  hide: () ->
    clearTimeout(@animationTimer)
    @icon.stop()
    @icon.remove()