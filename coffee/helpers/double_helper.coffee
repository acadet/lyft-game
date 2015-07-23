class DoubleHelper
  @TOLERANCE = 3

  @compare: (a, b, tolerance) ->
    tolerance = DoubleHelper.TOLERANCE unless tolerance?
    Math.abs(a - b) <= tolerance
