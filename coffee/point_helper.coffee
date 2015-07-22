class PointHelper
  @compare: (p1, p2, tolerance) ->
    DoubleHelper.compare(p1.getX(), p2.getX(), tolerance) and DoubleHelper.compare(p1.getY(), p2.getY(), tolerance)