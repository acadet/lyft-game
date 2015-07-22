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
    if PointHelper.compare(@currentPosition, point)
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
                    @_animateTo(point, callback)
                ,
                  1 / Car.SPEED
                )

  moveTo: (target) ->
    return unless @grid.isWithinAStreet(target)

    if PointHelper.compare(@currentPosition, target)
      # I am on spot
      return

    if @grid.isACrossStreet(@currentPosition)
      @currentStreetDirection = StreetDirection.CROSS

    callback = () => @moveTo(target)

    verticalMove = () =>
      if @currentPosition.getY() <= target.getY()
        @_animateTo(
                     @grid.getNextVerticalCross(@currentPosition),
                     StreetDirection.VERTICAL,
                     Orientation.BOTTOM,
                     callback
                   )
      else
        @_animateTo(
                     @grid.getPrevVerticalCross(@currentPosition),
                     StreetDirection.VERTICAL,
                     Orientation.TOP,
                     callback
                   )
      @currentStreetDirection = StreetDirection.VERTICAL
    horizontalMove = () =>
      if @currentPosition.getX() <= target.getX()
        @_animateTo(
                     @grid.getNextHorizontalCross(@currentPosition),
                     StreetDirection.HORIZONTAL,
                     Orientation.RIGHT
                     callback
                   )
      else
        @_animateTo(
                     @grid.getPrevHorizontalCross(@currentPosition),
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
      if DoubleHelper.compare(@currentPosition.getX(), target.getX())
        verticalMove()
      else
        horizontalMove()
