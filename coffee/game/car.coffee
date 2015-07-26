class Car
  class StreetDirection
    @CROSS = 0
    @HORIZONTAL = 1
    @VERTICAL = 2

  class Orientation
    @UP = 0
    @RIGHT = 1
    @DOWN = 2
    @LEFT = 3

  constructor: (source, grid, speed) ->
    @source = $(source)
    @carWidth = parseInt(@source.attr('width'))
    @carHeight = parseInt(@source.attr('height'))
    @grid = grid
    @speed = speed
    @currentPosition = @grid.randomCrossStreets()
    @_refreshPosition()
    @currentStreetDirection = StreetDirection.CROSS
    @currentAnimation = null

  _refreshPosition: () ->
    @source.attr('x', @currentPosition.getX() - @carWidth / 2)
    @source.attr('y', @currentPosition.getY() - @carHeight / 2)

  _animateTo: (point, direction, orientation, callback) ->
    if PointHelper.compare(@currentPosition, point)
      callback()
    else
      @currentAnimation = setTimeout(
                                      () =>
                                        k = -1
                                        if orientation is Orientation.DOWN or orientation is Orientation.RIGHT
                                          k = 1

                                        if direction is StreetDirection.HORIZONTAL
                                          @currentPosition.setX(@currentPosition.getX() + k)
                                        else
                                          @currentPosition.setY(@currentPosition.getY() + k)
                                        @_refreshPosition()
                                        EventBus.get('Car').post(CarMoveEvent.NAME, new CarMoveEvent())
                                        @_animateTo(point, direction, orientation, callback)
                                    ,
                                      1 / @speed
                                    )

  _moveTo: (target) ->
    if PointHelper.compare(@currentPosition, target)
      # I am on spot
      return

    if @grid.isACrossStreet(@currentPosition)
      @currentStreetDirection = StreetDirection.CROSS

    callback = () => @_moveTo(target)

    neighborhoodLimit = @grid.getBlockSize() - @grid.getStreetSize() / 2

    verticalMove = () =>
      nextPosition = null
      orientation = null

      statement = Math.abs(target.getY() - @currentPosition.getY()) < neighborhoodLimit
      statement &= DoubleHelper.compare(target.getX(), @currentPosition.getX())
      if statement
        nextPosition = target
        if target.getY() <= @currentPosition.getY()
          orientation = Orientation.UP
        else
          orientation = Orientation.DOWN
      else
        if target.getY() <= @currentPosition.getY()
          orientation = Orientation.UP
          nextPosition = @grid.getPrevHorizontalCross(@currentPosition)
        else
          orientation = Orientation.DOWN
          nextPosition = @grid.getNextHorizontalCross(@currentPosition)

      @currentStreetDirection = StreetDirection.VERTICAL
      @_animateTo(nextPosition, StreetDirection.VERTICAL, orientation, callback)

    horizontalMove = () =>
      nextPosition = null
      orientation = null

      statement = Math.abs(target.getX() - @currentPosition.getX()) < neighborhoodLimit
      statement &= DoubleHelper.compare(target.getY(), @currentPosition.getY())
      if statement
        nextPosition = target
        if target.getX() <= @currentPosition.getX()
          orientation = Orientation.LEFT
        else
          orientation = Orientation.RIGHT
      else
        if target.getX() <= @currentPosition.getX()
          orientation = Orientation.LEFT
          nextPosition = @grid.getPrevVerticalCross(@currentPosition)
        else
          orientation = Orientation.RIGHT
          nextPosition = @grid.getNextVerticalCross(@currentPosition)

      @currentStreetDirection = StreetDirection.HORIZONTAL
      @_animateTo(nextPosition, StreetDirection.HORIZONTAL, orientation, callback)

    if @currentStreetDirection is StreetDirection.VERTICAL
      verticalMove()
    else if @currentStreetDirection is StreetDirection.HORIZONTAL
      horizontalMove()
    else
      if DoubleHelper.compare(target.getX(), @currentPosition.getX())
        # Same vertical alignment
        verticalMove()
      else if DoubleHelper.compare(target.getY(), @currentPosition.getY())
        # Same horizontal alignment
        horizontalMove()
      else if Math.abs(target.getX() - @currentPosition.getX()) < neighborhoodLimit
        verticalMove()
      else if Math.abs(target.getY() - @currentPosition.getY()) < neighborhoodLimit
        horizontalMove()
      else
        shouldMoveHorizontal = Math.round(Math.random()) is 0
        if shouldMoveHorizontal
          horizontalMove()
        else
          verticalMove()

  getSpeed: () ->
    @speed

  setSpeed: (v) ->
    @speed = v

  getCurrentPosition: () ->
    @currentPosition

  requestMove: (target) ->
    return unless @grid.isWithinAStreet(target)

    if @currentAnimation?
      clearTimeout(@currentAnimation)
      @currentAnimation = null

    @_moveTo(@grid.realign(target))