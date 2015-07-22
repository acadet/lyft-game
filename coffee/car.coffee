class Car
  @SPEED = 2

  class StreetDirection
    @CROSS = 0
    @HORIZONTAL = 1
    @VERTICAL = 2

  class Orientation
    @UP = 0
    @RIGHT = 1
    @DOWN = 2
    @LEFT = 3

  constructor: (source, grid) ->
    @source = $(source)
    @carWidth = parseInt(@source.attr('width'))
    @carHeight = parseInt(@source.attr('height'))
    @grid = grid
    @currentPosition = @grid.randomCrossStreets()
    @_refreshPosition()
    @currentStreetDirection = StreetDirection.CROSS
    @currentTimer = null

  _refreshPosition: () ->
    @source.attr('x', @currentPosition.getX() - @carWidth / 2)
    @source.attr('y', @currentPosition.getY() - @carHeight / 2)

  _animateTo: (point, direction, orientation, callback) ->
    if PointHelper.compare(@currentPosition, point)
      callback()
    else
      @currentTimer = setTimeout(
                                  () =>
                                    @currentTimer = null
                                    k = -1
                                    if orientation is Orientation.DOWN or orientation is Orientation.RIGHT
                                      k = 1

                                    if direction is StreetDirection.HORIZONTAL
                                      @currentPosition.setX(@currentPosition.getX() + k)
                                    else
                                      @currentPosition.setY(@currentPosition.getY() + k)
                                    @_refreshPosition()
                                    @_animateTo(point, direction, orientation, callback)
                                ,
                                  1 / Car.SPEED
                                )

  _moveTo: (target) ->
    if PointHelper.compare(@currentPosition, target, @grid.getStreetSize())
      # I am on spot
      return

    if @currentTimer?
      clearTimeout(@currentTimer)
      @currentTimer = null

    if @grid.isACrossStreet(@currentPosition)
      @currentStreetDirection = StreetDirection.CROSS

    alignedTarget = @grid.realign(target)
    callback = () => @_moveTo(target)

    verticalMove = () =>
      p = alignedTarget
      needMilestone = not DoubleHelper.compare(alignedTarget.getX(), @currentPosition.getX())

      if @currentPosition.getY() <= target.getY()
        p = @grid.getNextHorizontalCross(@currentPosition) if needMilestone
        @_animateTo(
                     p
                     StreetDirection.VERTICAL,
                     Orientation.DOWN,
                     callback
                   )
      else
        p = @grid.getPrevHorizontalCross(@currentPosition) if needMilestone
        @_animateTo(
                     p,
                     StreetDirection.VERTICAL,
                     Orientation.UP,
                     callback
                   )
      @currentStreetDirection = StreetDirection.VERTICAL
    horizontalMove = () =>
      p = alignedTarget
      needMilestone = not DoubleHelper.compare(alignedTarget.getY(), @currentPosition.getY())
      if @currentPosition.getX() <= target.getX()
        p = @grid.getNextVerticalCross(@currentPosition) if needMilestone
        @_animateTo(
                     p,
                     StreetDirection.HORIZONTAL,
                     Orientation.RIGHT
                     callback
                   )
      else
        p = @grid.getPrevVerticalCross(@currentPosition) if needMilestone
        @_animateTo(
                     p,
                     StreetDirection.HORIZONTAL,
                     Orientation.LEFT,
                     callback
                   )
      @currentStreetDirection = StreetDirection.HORIZONTAL

    if @currentStreetDirection is StreetDirection.VERTICAL
      verticalMove()
    else if @currentStreetDirection is StreetDirection.HORIZONTAL
      horizontalMove()
    else
      # I am on a junction, I can move in both directions
      if DoubleHelper.compare(@currentPosition.getX(), alignedTarget.getX())
        verticalMove()
      else if DoubleHelper.compare(@currentPosition.getY(), alignedTarget.getY())
        horizontalMove()
      else
        if @grid.shouldIMoveHorizontal(@currentPosition, alignedTarget)
          horizontalMove()
        else
          verticalMove()

  requestMove: (target) ->
    return unless @grid.isWithinAStreet(target)
    @_moveTo(target)