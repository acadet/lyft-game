class Balloon
  @COLORS = ['red', 'blue', 'purple', 'green']
  @SIZE = 30

  constructor: (grid, period) ->
    @grid = grid

    setInterval(
                 () =>
                   p = @grid.randomPosition()
                   c = Math.round(Math.random() * (Balloon.COLORS.length - 1))
                   @grid.getSnap().image(
                                          "imgs/#{Balloon.COLORS[c]}-balloon.png",
                                          p.getX() / Balloon.SIZE,
                                          p.getY() / Balloon.SIZE,
                                          Balloon.SIZE,
                                          Balloon.SIZE
                                        )
               ,
                 period
               )