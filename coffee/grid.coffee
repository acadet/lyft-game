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
      return true if DoubleHelper.compare(position.getX(), x, @streetSize / 2)

    for j in [0...@horizontalStreetNumber]
      y = j * @blockSize
      return true if DoubleHelper.compare(position.getY(), y, @streetSize / 2)

    return false
#    semiStreet = @streetSize / 2
#    a = position.getX() % @blockSize
#    return true unless (a < (@blockSize - semiStreet) and a > semiStreet)
#    b = position.getY() % @blockSize
#    return true unless (b < (@blockSize - semiStreet) and b > semiStreet)
#    return false
  #return position.getX() % @blockSize <= @streetSize or position.getY() % @blockSize <= @streetSize

  isACrossStreet: (position) ->
    a = false
    for i in [0...@verticalStreetNumber]
      x = i * @blockSize
      if DoubleHelper.compare(position.getX(), x, @streetSize / 2)
        a = true
        break

    b = false
    for j in [0...@horizontalStreetNumber]
      y = j * @blockSize
      if DoubleHelper.compare(position.getY(), y, @streetSize / 2)
        b = true
        break

    return a and b
#    semiStreet = @streetSize / 2
#    a = position.getX() % @blockSize
#    return false if (a < (@blockSize - semiStreet) and a > semiStreet)
#    b = position.getY() % @blockSize
#    return false if (b < (@blockSize - semiStreet) and b > semiStreet)
#    return true
  #return position.getX() % @blockSize <= @streetSize and position.getY() % @blockSize <= @streetSize

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
    j = Math.floor(position.getY() / @blockSize) - 1
    return position if j < 0
    return new Point(position.getX(), j * @blockSize)

  getNextHorizontalCross: (position) ->
    j = Math.floor(position.getY() / @blockSize) + 1
    return position if j >= @horizontalStreetNumber
    return new Point(position.getX(), j * @blockSize)

  getPrevVerticalCross: (position) ->
    i = Math.floor(position.getX() / @blockSize) - 1
    return position if i < 0
    return new Point(i * @blockSize, position.getY())

  getNextVerticalCross: (position) ->
    i = Math.floor(position.getX() / @blockSize) + 1
    return position if i >= @verticalStreetNumber
    return new Point(i * @blockSize, position.getY())