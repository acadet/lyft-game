class Zone
  @COLORS = ['red', 'blue', 'purple', 'green']
  @SIZE = 30

  constructor: (id, grid, color) ->
    @id = id
    @grid = grid

    # Set marker
    @color = color

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

  setDuration: (v) ->
    @duration = v

  setAnimationDelay: (v) ->
    @animationDelay = v

  getImgExtension: () ->
    # TO IMPL

  postVanished: () ->
    # TO IMPL

  isNearMe: (point) ->
    PointHelper.compare(point, @position, @grid.getStreetSize() / 2)

  show: () ->
    @position = @grid.randomPosition()
    @icon = @grid.getSnap().image(
                                   "imgs/#{@color}-#{@getImgExtension()}.png",
                                   @position.getX() - Zone.SIZE / 2,
                                   @position.getY() - Zone.SIZE / 2,
                                   Zone.SIZE,
                                   Zone.SIZE
                                 )
    @animationTimer = setTimeout(
                                  () => @_animate(),
                                  @animationDelay
                                )

  hide: () ->
    clearTimeout(@animationTimer) if @animationTimer?
    @icon.stop()
    @icon.remove()

  @randomColor: () ->
    colorIndex = Math.round(Math.random() * (Zone.COLORS.length - 1))
    return Zone.COLORS[colorIndex]