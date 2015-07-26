class Zone
  @SIZE = 30

  @colors = [
    {
      label: 'red'
      inUse: false
    },
    {
      label: 'blue'
      inUse: false
    },
    {
      label: 'purple'
      inUse: false
    },
    {
      label: 'green'
      inUse: false
    }
  ]
  @colorInUse = 0

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
    PointHelper.compare(point, @position, Zone.SIZE)

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

  @provideColor: () ->
    randomIndex = () => Math.round(Math.random() * (Zone.colors.length - 1))

    if Zone.colorInUse >= Zone.colors.length
      Zone.colorInUse++
      return Zone.colors[randomIndex()].label

    while true
      color = Zone.colors[randomIndex()]
      if not color.inUse
        color.inUse = true
        Zone.colorInUse++
        return color.label