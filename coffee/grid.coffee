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
    for i in [0...Math.max(@horizontalStreetNumber, @verticalStreetNumber)]
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
    for i in [0...@verticalStreetNumber]
      x = i * @blockSize
      return true if DoubleHelper.compare(position.getX(), x, @streetSize)

    for j in [0...@horizontalStreetNumber]
      y = j * @blockSize
      return true if DoubleHelper.compare(position.getY(), y, @streetSize)

    return false

  isACrossStreet: (position) ->
    a = false
    for i in [0...@verticalStreetNumber]
      x = i * @blockSize
      if DoubleHelper.compare(position.getX(), x, @streetSize)
        a = true
        break

    b = false
    for j in [0...@horizontalStreetNumber]
      y = j * @blockSize
      if DoubleHelper.compare(position.getY(), y, @streetSize)
        b = true
        break

    return a and b

  getStreetSize: () ->
    @streetSize

  realign: (position) ->
    x = position.getX()
    for i in [0...@verticalStreetNumber]
      a = i * @blockSize
      if DoubleHelper.compare(a, position.getX(), @streetSize / 2)
        x = a
        break

    y = position.getY()
    for j in [0...@horizontalStreetNumber]
      b = j * @blockSize
      if DoubleHelper.compare(b, position.getY(), @streetSize / 2)
        y = b
        break

    return new Point(x, y)

  getPrevHorizontalCross: (position) ->
    j = Math.ceil(position.getY() / @blockSize) - 1
    return position if j < 0
    return new Point(position.getX(), j * @blockSize)

  getNextHorizontalCross: (position) ->
    j = Math.ceil(position.getY() / @blockSize) + 1
    return position if j >= @horizontalStreetNumber
    return new Point(position.getX(), j * @blockSize)

  getPrevVerticalCross: (position) ->
    i = Math.ceil(position.getX() / @blockSize) - 1
    return position if i < 0
    return new Point(i * @blockSize, position.getY())

  getNextVerticalCross: (position) ->
    i = Math.ceil(position.getX() / @blockSize) + 1
    return position if i >= @verticalStreetNumber
    return new Point(i * @blockSize, position.getY())

  shouldIMoveHorizontal: (start, end) ->
    return Math.abs(end.getY() - start.getY()) < @blockSize