class Point
  constructor: (x, y) ->
    @x = x
    @y = y

  getX: () ->
    @x

  setX: (value) ->
    @x = value

  getY: () ->
    @y

  setY: (value) ->
    @y = value

  toString: () ->
    "#{@x} - #{@y}"