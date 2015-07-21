class Grid
  constructor: (source, blockSize, streetSize) ->
    @source = $(source)
    @snap = Snap(source)
    @blockSize = blockSize
    @streetSize = streetSize

    @gridWidth = @source.outerWidth()
    @gridHeight = @source.outerHeight()
    @verticalStreetNumber = Math.floor(@gridWidth / @blockSize) + 1
    @horizontalStreetNumber = Math.floor(@gridHeight / @blockSize) + 1

  render: () ->
    for i in [0..Math.max(@horizontalStreetNumber, @verticalStreetNumber)]
      z = i * @blockSize - @streetSize / 2
      horizontalStreet = @snap.rect(0, z, @gridWidth, @streetSize) unless i >= @horizontalStreetNumber
      verticalStreet = @snap.rect(z, 0, @streetSize, @gridHeight) unless i >= @verticalStreetNumber
  # TODO: customize streets

  # Returns a random cross street junction (via a point)
  randomCrossStreets: () ->
    i = Math.round(Math.random() * (@verticalStreetNumber - 1))
    j = Math.round(Math.random() * (@horizontalStreetNumber - 1))

    return new Point(i * @blockSize, j * @blockSize)

  isWithinAStreet: (position) ->
    return ((position.getX() % @blockSize) is 0) or ((position.getY() % @blockSize) is 0)

  isACrossStreet: (position) ->
    return ((position.getX() % @blockSize) is @streetSize) and ((position.getY() % @blockSize) is 0)

  getPrevHorizontalCross: (position) ->
    j = Math.floor(position.getY() / @horizontalStreetNumber) - 1
    return position if j < 0
    return new Point(position.getX(), j * @blockSize)

  getNextHorizontalCross: (position) ->
    j = Math.floor(position.getY() / @horizontalStreetNumber) + 1
    return position if j >= @horizontalStreetNumber
    return new Point(position.getX(), j * @blockSize)

  getPrevVerticalCross: (position) ->
    i = Math.floor(position.getX() / @verticalStreetNumber) - 1
    return position if j < 0
    return new Point(i * @blockSize, position.getY())

  getNextVerticalCross: (position) ->
    i = Math.floor(position.getX() / @verticalStreetNumber) + 1
    return position if j >= @verticalStreetNumber
    return new Point(i * @blockSize, position.getY())