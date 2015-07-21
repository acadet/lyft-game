class Car
  @SPEED: 2

  class StreetDirection
    @CROSS = 0
    @HORIZONTAL = 1
    @VERTICAL = 2

  constructor: (source, grid) ->
    @source = $(source)
    @grid = grid
    @currentPosition = @grid.randomCrossStreets()
    @currentStreetDirection = StreetDirection.CROSS

  _setCarPosition: (position) ->
    @source.css
      top: position.getY()
      left: position.getX()

  _animateTo: (point, callback) ->
    if PointHelper.compare(@currentPosition, point)
      callback()
    else
      setTimeout(
                  () =>
                    @currentPosition.setX(@currentPosition.getX() + 1)
                    @currentPosition.setY(@currentPosition.getY() + 1)
                    @_animateTo(point, callback)
                ,
                  1 / Car.SPEED
                )

  moveTo: (target) ->
    return if not @grid.isWithinAStreet(target)

    if PointHelper.compare(@currentPosition, target)
      # I am on spot
      if @grid.isACrossStreet(@currentPosition)
        @currentStreetDirection = StreetDirection.CROSS
      return

    callback = () => @moveTo(target)

    verticalMove = () =>
      if @currentPosition.getY() <= target.getY()
        @_animateTo(@grid.getNextVerticalCross(@currentPosition), callback)
      else
        @_animateTo(@grid.getPrevVerticalCross(@currentPosition), callback)
    horizontalMove = () =>
      if @currentPosition.getX() <= target.getX()
        @_animateTo(@grid.getNextHorizontalCross(@currentPosition), callback)
      else
        @_animateTo(@grid.getPrevHorizontalCross(@currentPosition), callback)

    if @currentStreetDirection is StreetDirection.VERTICAL
      verticalMove()
    else if @currentStreetDirection is StreetDirection.HORIZONTAL
      horizontalMove()
    else
      if DoubleHelper.compare(@currentPosition.getX(), target.getX())
        verticalMove()
      else
        horizontalMove()
