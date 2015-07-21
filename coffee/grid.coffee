class Grid
  constructor: (source, blockSize, streetSize) ->
    @source = $(source)
    @snap = Snap(source)
    @blockSize = blockSize
    @streetSize = streetSize

    @gridWidth = @source.outerWidth()
    @gridHeight = @source.outerHeight()
    @verticalStreetNumber = Math.floor(@gridWidth / @blockSize)
    @horizontalStreetNumber = Math.floor(@gridHeight / @blockSize)

  render: () ->
    for i in [0..Math.max(@horizontalStreetNumber, @verticalStreetNumber)]
      z = i * @blockSize - @streetSize / 2
      horizontalStreet = @snap.rect(0, z, @gridWidth, @streetSize) unless i > @horizontalStreetNumber
      verticalStreet = @snap.rect(z, 0, @streetSize, @gridHeight) unless i > @verticalStreetNumber

  # Returns a random cross street junction (via a point)
  randomCrossStreets: () ->
    i = Math.round(Math.random() * (@horizontalStreetNumber - 1))
    j = Math.round(Math.random() * (@verticalStreetNumber - 1))

    return new Point(i * @blockSize, j * @blockSize)

  isWithinAStreet: (position) ->
    return ((position.getX() % @blockSize) <= @streetSize) or ((position.getY() % @blockSize) <= @streetSize)

  isACrossStreet: (position) ->
    return ((position.getX() % @blockSize) <= @streetSize) and ((position.getY() % @blockSize) <= @streetSize)

  getPrevHorizontalCross: (position) ->
    j = Math.floor(position.getY() / @horizontalStreetNumber)
    return new Point(position.getX(), j * @blockSize)

  getNextHorizontalCross: (position) ->
    p = @getPrevHorizontalCross(position)
    return new Point(p.getX(), p.getY() + @blockSize)

  getPrevVerticalCross: (position) ->
    i = Math.floor(position.getX() / @verticalStreetNumber)
    return new Point(i * @blockSize, position.getY())

  getNextVerticalCross: (position) ->
    p = @getPrevVerticalCross(position)
    return new Point(p.getX() + @blockSize, p.getY())