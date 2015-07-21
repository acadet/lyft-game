class DoubleHelper
  @TOLERANCE: 3

  @compare: (d1, d2, tolerance) ->
    tolerance = @TOLERANCE unless tolerance?
    Math.abs(a - b) <= tolerance
