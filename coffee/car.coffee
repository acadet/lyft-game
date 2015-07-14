class Car
  @MARGIN = 3

  class StreetDirection
    @CROSS = 0
    @HORIZONTAL = 1
    @VERTICAL = 2

  constructor: (grid) ->
    @grid = grid
    @currentPosition = @grid.randomCrossStreets()
    @currentStreetDirection = StreetDirection.CROSS

  _compareDouble: (a, b) ->
    return Math.abs(a - b) <= Car.MARGIN

  _comparePoints: (p1, p2) ->
    return @_compareDouble(p1.getX(), p2.getX()) and @_compareDouble(p1.getY(), p2.getY())

  _animateTo: (point, callback) ->

  moveTo: (target) ->
    return if not @grid.isWithinAStreet(target)

    if @_comparePoints(@currentPosition, target)
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
      if @_compareDouble(@currentPosition.getX(), target.getX())
        verticalMove()
      else
        horizontalMove()
