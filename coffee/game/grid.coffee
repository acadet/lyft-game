class Grid
  @TARGET_TOLERANCE = 20
  @FILL_COLOR = '#fff'
  @STROKE_COLOR = '#EAE2D8'

  constructor: (source, blockNumber, streetSize) ->
    @source = $(source)
    @snap = Snap(source)
    @streetSize = streetSize

    @gridWidth = @source.width()
    @gridHeight = @source.height()
    @blockWidth = Math.floor(@gridWidth / blockNumber)
    @blockHeight = Math.floor(@gridHeight / blockNumber)
    @verticalStreetNumber = blockNumber + 1
    @horizontalStreetNumber = blockNumber + 1

  getSource: () ->
    @source

  getSnap: () ->
    @snap

  getStreetSize: () ->
    @streetSize

  getBlockWidth: () ->
    @blockWidth

  getBlockHeight: () ->
    @blockHeight

  # Builds grid
  render: () ->
    for i in [0...Math.max(@horizontalStreetNumber, @verticalStreetNumber)]
      # Build street only if not done yet
      horizontalStreet = @snap.rect(0, i * @blockHeight, @gridWidth, @streetSize) unless i >= @horizontalStreetNumber
      verticalStreet = @snap.rect(i * @blockWidth, 0, @streetSize, @gridHeight) unless i >= @verticalStreetNumber

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
        square = @snap.circle(i * @blockWidth + @streetSize / 2, j * @blockHeight + @streetSize / 2, @streetSize)
        square.attr(
                     fill: Grid.FILL_COLOR
                   )

  # Returns a random cross street junction (via a point)
  randomCrossStreets: () ->
    i = Math.round(Math.random() * (@verticalStreetNumber - 1))
    j = Math.round(Math.random() * (@horizontalStreetNumber - 1))

    return new Point(i * @blockWidth + @streetSize / 2, j * @blockHeight + @streetSize / 2)

  # Returns a random position within a street
  randomPosition: () ->
    isHorizontal = Math.round(Math.random()) is 0
    x = null
    y = null

    if isHorizontal
      x = Math.round(Math.random() * @gridWidth)
      y = Math.round(Math.random() * (@horizontalStreetNumber - 1)) * @blockHeight + @streetSize / 2
    else
      x = Math.round(Math.random() * (@verticalStreetNumber - 1)) * @blockWidth + @streetSize / 2
      y = Math.round(Math.random() * @gridHeight)

    return new Point(x, y)

  # Returns true if the provided position is within a street
  isWithinAStreet: (position) ->
    for i in [0...@verticalStreetNumber] # Is in a vertical gutter
      x = i * @blockWidth + @streetSize / 2
      return true if DoubleHelper.compare(position.getX(), x, @streetSize / 2 + Grid.TARGET_TOLERANCE)

    for j in [0...@horizontalStreetNumber] # Is in a horizontal gutter
      y = j * @blockHeight + @streetSize / 2
      return true if DoubleHelper.compare(position.getY(), y, @streetSize / 2 + Grid.TARGET_TOLERANCE)

    return false

  # Returns true if position is at a junction
  # Same algorithm than isWithinAStreet but the position
  # must match both conditions
  isACrossStreet: (position) ->
    a = false
    for i in [0...@verticalStreetNumber]
      x = i * @blockWidth + @streetSize / 2
      if DoubleHelper.compare(position.getX(), x, @streetSize / 2)
        a = true
        break

    return false unless a? # Not in a vertical gutter, do not keep going

    b = false
    for j in [0...@horizontalStreetNumber]
      y = j * @blockHeight + @streetSize / 2
      if DoubleHelper.compare(position.getY(), y, @streetSize / 2)
        b = true
        break

    return (a and b)

  # Updates provided position to a "perfect" point in the grid
  realign: (position) ->
    x = position.getX()
    for i in [0...@verticalStreetNumber]
      a = i * @blockWidth + @streetSize / 2
      if DoubleHelper.compare(a, position.getX(), @streetSize / 2 + Grid.TARGET_TOLERANCE)
        x = a
        break

    y = position.getY()
    for j in [0...@horizontalStreetNumber]
      b = j * @blockHeight + @streetSize / 2
      if DoubleHelper.compare(b, position.getY(), @streetSize / 2 + Grid.TARGET_TOLERANCE)
        y = b
        break

    return new Point(x, y)

  # Returns the closest previous horizontal junction from the provided
  # position
  getPrevHorizontalCross: (position) ->
    y = position.getY()
    # If the position is at the south of the junction, it is still
    # matching the same north junction
    y -= (y % @blockHeight) if y % @blockHeight <= @streetSize
    j = Math.ceil(y / @blockHeight) - 1
    return position if j < 0
    return new Point(position.getX(), j * @blockHeight + @streetSize / 2)

  # Returns the closest next horizontal junction from the provided position
  getNextHorizontalCross: (position) ->
    y = position.getY()
    # Trick if the position is in a edge position of the junction
    y++ if y % @blockHeight is 0
    j = Math.ceil(y / @blockHeight)
    return position if j >= @horizontalStreetNumber
    return new Point(position.getX(), j * @blockHeight + @streetSize / 2)

  # Returns the closest previous vertical junction from the provided position
  getPrevVerticalCross: (position) ->
    x = position.getX()
    x -= (x % @blockWidth) if x % @blockWidth <= @streetSize
    i = Math.ceil(x / @blockWidth) - 1
    return position if i < 0
    return new Point(i * @blockWidth + @streetSize / 2, position.getY())

  # Returns the closest next vertical junction from the provided position
  getNextVerticalCross: (position) ->
    x = position.getX()
    x++ if x % @blockWidth is 0
    i = Math.ceil(x / @blockWidth)
    return position if i >= @verticalStreetNumber
    return new Point(i * @blockWidth + @streetSize / 2, position.getY())