class DoubleHelper
  @TOLERANCE = 3

  @compare: (a, b, tolerance) ->
    tolerance = @TOLERANCE unless tolerance?
    Math.abs(a - b) <= tolerance
