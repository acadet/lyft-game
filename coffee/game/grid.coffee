class Grid
  @FILL_COLOR = '#fff'
  @STROKE_COLOR = '#EAE2D8'

  constructor: (source, blockSize, streetSize) ->
    @source = $(source)
    @snap = Snap(source)
    @blockSize = blockSize
    @streetSize = streetSize

    @gridWidth = @source.width() - (@source.outerWidth() % @blockSize)
    @gridHeight = @source.height() - (@source.outerHeight() % @blockSize)
    @verticalStreetNumber = Math.floor(@gridWidth / @blockSize) + 1
    @horizontalStreetNumber = Math.floor(@gridHeight / @blockSize) + 1

  getSource: () ->
    @source

  getSnap: () ->
    @snap

  getStreetSize: () ->
    @streetSize

  getBlockSize: () ->
    @blockSize

  # Builds grid
  render: () ->
    for i in [0...Math.max(@horizontalStreetNumber, @verticalStreetNumber)]
      z = i * @blockSize
      # Build street only if not done yet
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

    # Build junctions
    for i in [0...@verticalStreetNumber]
      for j in [0...@horizontalStreetNumber]
        square = @snap.circle(i * @blockSize + @streetSize / 2, j * @blockSize + @streetSize / 2, @streetSize)
        square.attr(
                     fill: Grid.FILL_COLOR
                   )

  # Returns a random cross street junction (via a point)
  randomCrossStreets: () ->
    i = Math.round(Math.random() * (@verticalStreetNumber - 1))
    j = Math.round(Math.random() * (@horizontalStreetNumber - 1))

    return new Point(i * @blockSize + @streetSize / 2, j * @blockSize + @streetSize / 2)

  # Returns a random position within a street
  randomPosition: () ->
    isHorizontal = Math.round(Math.random()) is 0
    x = null
    y = null

    if isHorizontal
      x = Math.round(Math.random() * @gridWidth)
      y = Math.round(Math.random() * (@horizontalStreetNumber - 1)) * @blockSize + @streetSize / 2
    else
      x = Math.round(Math.random() * (@verticalStreetNumber - 1)) * @blockSize + @streetSize / 2
      y = Math.round(Math.random() * @gridHeight)

    return new Point(x, y)

  # Returns true if the provided position is within a street
  isWithinAStreet: (position) ->
    for i in [0...@verticalStreetNumber] # Is in a vertical gutter
      x = i * @blockSize + @streetSize / 2
      return true if DoubleHelper.compare(position.getX(), x, @streetSize / 2)

    for j in [0...@horizontalStreetNumber] # Is in a horizontal gutter
      y = j * @blockSize + @streetSize / 2
      return true if DoubleHelper.compare(position.getY(), y, @streetSize / 2)

    return false

  # Returns true if position is at a junction
  # Same algorithm than isWithinAStreet but the position
  # must match both conditions
  isACrossStreet: (position) ->
    a = false
    for i in [0...@verticalStreetNumber]
      x = i * @blockSize + @streetSize / 2
      if DoubleHelper.compare(position.getX(), x, @streetSize / 2)
        a = true
        break

    return false unless a? # Not in a vertical gutter, do not keep going

    b = false
    for j in [0...@horizontalStreetNumber]
      y = j * @blockSize + @streetSize / 2
      if DoubleHelper.compare(position.getY(), y, @streetSize / 2)
        b = true
        break

    return (a and b)

  # Updates provided position to a "perfect" point in the grid
  realign: (position) ->
    x = position.getX()
    for i in [0...@verticalStreetNumber]
      a = i * @blockSize + @streetSize / 2
      if DoubleHelper.compare(a, position.getX(), @streetSize / 2)
        x = a
        break

    y = position.getY()
    for j in [0...@horizontalStreetNumber]
      b = j * @blockSize + @streetSize / 2
      if DoubleHelper.compare(b, position.getY(), @streetSize / 2)
        y = b
        break

    return new Point(x, y)

  # Returns the closest previous horizontal junction from the provided
  # position
  getPrevHorizontalCross: (position) ->
    y = position.getY()
    # If the position is at the south of the junction, it is still
    # matching the same north junction
    y -= (y % @blockSize) if y % @blockSize <= @streetSize
    j = Math.ceil(y / @blockSize) - 1
    return position if j < 0
    return new Point(position.getX(), j * @blockSize + @streetSize / 2)

  # Returns the closest next horizontal junction from the provided position
  getNextHorizontalCross: (position) ->
    y = position.getY()
    # Trick if the position is in a edge position of the junction
    y++ if y % @blockSize is 0
    j = Math.ceil(y / @blockSize)
    return position if j >= @horizontalStreetNumber
    return new Point(position.getX(), j * @blockSize + @streetSize / 2)

  # Returns the closest previous vertical junction from the provided position
  getPrevVerticalCross: (position) ->
    x = position.getX()
    x -= (x % @blockSize) if x % @blockSize <= @streetSize
    i = Math.ceil(x / @blockSize) - 1
    return position if i < 0
    return new Point(i * @blockSize + @streetSize / 2, position.getY())

  # Returns the closest next vertical junction from the provided position
  getNextVerticalCross: (position) ->
    x = position.getX()
    x++ if x % @blockSize is 0
    i = Math.ceil(x / @blockSize)
    return position if i >= @verticalStreetNumber
    return new Point(i * @blockSize + @streetSize / 2, position.getY())

  shouldIMoveHorizontal: (start, end) ->
    return Math.abs(end.getY() - start.getY()) < @blockSize