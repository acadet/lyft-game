class Grid
  constructor: (source, blockSize, streetSize) ->
    @source = $(source)
    @snap = Snap(source)
    @blockSize = blockSize
    @streetSize = streetSize

  render: () ->
    width = @source.outerWidth()
    height = @source.outerHeight()
    verticalGutterNumber = Math.floor(width / @blockSize)
    horizontalGutterNumber = Math.floor(height / @blockSize)

    for i in [0..Math.max(horizontalGutterNumber, verticalGutterNumber)]
      z = i * @blockSize - @streetSize / 2
      horizontalStreet = @snap.rect(0, z, width, @streetSize) unless i >= horizontalGutterNumber
      verticalStreet = @snap.rect(z, 0, @streetSize, height) unless i >= verticalGutterNumber
