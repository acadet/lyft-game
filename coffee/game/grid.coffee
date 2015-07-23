class Grid
  @FILL_COLOR = '#fff'
  @STROKE_COLOR = '#EAE2D8'

  constructor: (source, blockSize, streetSize) ->
    @source = $(source)
    @snap = Snap(source)
    @blockSize = blockSize
    @streetSize = streetSize

    @gridWidth = @source.outerWidth()
    @gridHeight = @source.outerHeight()
    @verticalStreetNumber = Math.floor(@gridWidth / @blockSize) + 1
    @horizontalStreetNumber = Math.floor(@gridHeight / @blockSize) + 1

  getSnap: () ->
    @snap

  render: () ->
    for i in [0...Math.max(@horizontalStreetNumber, @verticalStreetNumber)]
      z = i * @blockSize - @streetSize / 2
      horizontalStreet = @snap.rect(0, z, @gridWidth, @streetSize) unless i >= @horizontalStreetNumber
      verticalStreet = @snap.rect(z, 0, @streetSize, @gridHeight) unless i >= @verticalStreetNumber

      horizontalStreet.attr(
                             fill: Grid.FILL_COLOR
                             stroke: Grid.STROKE_COLOR
                           )
      verticalStreet.attr(
                           fill: Grid.FILL_COLOR
                           stroke: Grid.STROKE_COLOR
                         )

    for i in [0...@verticalStreetNumber]
      for j in [0...@horizontalStreetNumber]
        square = @snap.circle(i * @blockSize, j * @blockSize, @streetSize)
        square.attr(
                     fill: Grid.FILL_COLOR
                   )

  # Returns a random cross street junction (via a point)
  randomCrossStreets: () ->
    i = Math.round(Math.random() * (@verticalStreetNumber - 1))
    j = Math.round(Math.random() * (@horizontalStreetNumber - 1))

    return new Point(i * @blockSize, j * @blockSize)

  randomPosition: () ->
    isHorizontal = Math.round(Math.random()) == 0
    if isHorizontal
      x = Math.round(Math.random() * @gridWidth)
      y = Math.round(Math.random() * (@horizontalStreetNumber - 1)) * @blockSize
      return new Point(x, y)
    else
      x = Math.round(Math.random() * (@verticalStreetNumber - 1)) * @blockSize
      y = Math.round(Math.random() * @gridHeight)
      return new Point(x, y)

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
    y = position.getY()
    y -= (y % @blockSize) if y % @blockSize <= @streetSize / 2
    j = Math.ceil(y / @blockSize) - 1
    return position if j < 0
    return new Point(position.getX(), j * @blockSize)

  getNextHorizontalCross: (position) ->
    y = position.getY()
    y -= (y % @blockSize) if y % @blockSize <= @streetSize / 2
    j = Math.ceil(y / @blockSize) + 1
    return position if j >= @horizontalStreetNumber
    return new Point(position.getX(), j * @blockSize)

  getPrevVerticalCross: (position) ->
    x = position.getX()
    x -= (x % @blockSize) if x % @blockSize <= @streetSize / 2
    i = Math.ceil(x / @blockSize) - 1
    return position if i < 0
    return new Point(i * @blockSize, position.getY())

  getNextVerticalCross: (position) ->
    x = position.getX()
    x -= (x % @blockSize) if x % @blockSize <= @streetSize / 2
    i = Math.ceil(x / @blockSize) + 1
    return position if i >= @verticalStreetNumber
    return new Point(i * @blockSize, position.getY())

  shouldIMoveHorizontal: (start, end) ->
    return Math.abs(end.getY() - start.getY()) < @blockSize