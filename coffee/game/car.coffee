# Manages car movements
class Car
  MAX_CALL_STACK = 30

  # Current direction of the car
  class StreetDirection
    @CROSS = 0
    @HORIZONTAL = 1
    @VERTICAL = 2

  # Current orientation of the car (for animating)
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

  _stopAnimation: () ->
    if @currentAnimation?
      clearTimeout(@currentAnimation)
      @currentAnimation = null

  _refreshPosition: () ->
    @source.attr('x', @currentPosition.getX() - @carWidth / 2)
    @source.attr('y', @currentPosition.getY() - @carHeight / 2)

  # Animates car pixel per pixel
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

  # Moves car from a milestone to another one, within the same neighborhood.
  # E.g. moving car to a cross street or directly to target
  _moveTo: (target) ->
    if @callStack >= MAX_CALL_STACK
      # Limit call stack if too many recursive calls
      @_stopAnimation()
      return

    @callStack++

    return if PointHelper.compare(@currentPosition, target) # I am on spot

    if @grid.isACrossStreet(@currentPosition)
      @currentStreetDirection = StreetDirection.CROSS

    callback = () => @_moveTo(target)

    neighborhoodWidthLimit = @grid.getBlockWidth() - @grid.getStreetSize() / 2
    neighborhoodHeightLimit = @grid.getBlockHeight() - @grid.getStreetSize() / 2

    verticalMove = () =>
      nextPosition = null
      orientation = null

      statement = Math.abs(target.getY() - @currentPosition.getY()) < neighborhoodHeightLimit
      statement &= DoubleHelper.compare(target.getX(), @currentPosition.getX())
      if statement # I can reach target directly (same street and same block)
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

      statement = Math.abs(target.getX() - @currentPosition.getX()) < neighborhoodWidthLimit
      statement &= DoubleHelper.compare(target.getY(), @currentPosition.getY())
      if statement # I can reach target directly (same street and same block)
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
      # I am on a cross street
      if DoubleHelper.compare(target.getX(), @currentPosition.getX())
        # Same vertical alignment
        verticalMove()
      else if DoubleHelper.compare(target.getY(), @currentPosition.getY())
        # Same horizontal alignment
        horizontalMove()
      else if Math.abs(target.getX() - @currentPosition.getX()) < neighborhoodWidthLimit
        # Same neighborhood and 2 streets from my location
        verticalMove()
      else if Math.abs(target.getY() - @currentPosition.getY()) < neighborhoodHeightLimit
        # Same neighborhood and 2 streets from my location
        horizontalMove()
      else
        # Too far. Random behavior
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

  # User has requested a move
  requestMove: (target) ->
    return unless @grid.isWithinAStreet(target)

    @callStack = 0
    @_stopAnimation()

    @_moveTo(@grid.realign(target))