class Car
  @SPEED = 2

  class StreetDirection
    @CROSS = 0
    @HORIZONTAL = 1
    @VERTICAL = 2

  class Orientation
    @TOP = 0
    @RIGHT = 1
    @BOTTOM = 2
    @LEFT = 3

  constructor: (source, grid) ->
    @source = $(source)
    @grid = grid
    @currentPosition = @grid.randomCrossStreets()
    @_refreshPosition()
    @currentStreetDirection = StreetDirection.CROSS

  _refreshPosition: () ->
    @source.attr('x', @currentPosition.getX())
    @source.attr('y', @currentPosition.getY())

  _animateTo: (point, direction, orientation, callback) ->
    if PointHelper.compare(@currentPosition, point, 0)
      callback()
    else
      setTimeout(
                  () =>
                    k = -1
                    if orientation is Orientation.BOTTOM or orientation is Orientation.RIGHT
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

  moveTo: (target) ->
    return unless @grid.isWithinAStreet(target)

    if PointHelper.compare(@currentPosition, target, @grid.getStreetSize())
      # I am on spot
      return

    if @grid.isACrossStreet(@currentPosition)
      @currentStreetDirection = StreetDirection.CROSS

    alignedTarget = @grid.realign(target)
    callback = () => @moveTo(target)

    verticalMove = () =>
      p = alignedTarget
      needMilestone = not DoubleHelper.compare(alignedTarget.getX(), @currentPosition.getX())

      if @currentPosition.getY() <= target.getY()
        p = @grid.getNextHorizontalCross(@currentPosition) if needMilestone
        console.log 'moving vertical bottom'
        @_animateTo(
                     p
                     StreetDirection.VERTICAL,
                     Orientation.BOTTOM,
                     callback
                   )
      else
        p = @grid.getPrevHorizontalCross(@currentPosition) if needMilestone
        console.log 'moving vertical top'
        @_animateTo(
                     p,
                     StreetDirection.VERTICAL,
                     Orientation.TOP,
                     callback
                   )
      @currentStreetDirection = StreetDirection.VERTICAL
    horizontalMove = () =>
      p = alignedTarget
      needMilestone = not DoubleHelper.compare(alignedTarget.getY(), @currentPosition.getY())
      if @currentPosition.getX() <= target.getX()
        p = @grid.getNextVerticalCross(@currentPosition) if needMilestone
        console.log 'moving horizontal right'
        @_animateTo(
                     p,
                     StreetDirection.HORIZONTAL,
                     Orientation.RIGHT
                     callback
                   )
      else
        p = @grid.getPrevVerticalCross(@currentPosition) if needMilestone
        console.log 'moving horizontal left'
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
        if Math.random() < 0.5
          horizontalMove()
        else
          verticalMove()
