class PointHelper
  @compare: (p1, p2) ->
    DoubleHelper.compare(p1.getX(), p2.getX()) and DoubleHelper.compare(p1.getY(), p2.getY())