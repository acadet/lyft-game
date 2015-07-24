class ScoreManager
  constructor: (selector) ->
    @displayer = $(selector)
    @currentScore = 0

    EventBus.get('RideEngine').register PickupZoneVanishedEvent.NAME, (z) => @onMissedPickup(z)
    EventBus.get('RideEngine').register DropZoneVanishedEvent.NAME, (z) => @onMissedDrop(z)
    EventBus.get('RideEngine').register DropEvent.NAME, (z) => @onDrop(z)

  _refreshScore: () ->
    if @currentScore < 0
      EventBus.get('ScoreManager').post GameOverEvent.NAME, new GameOverEvent()
    else
      @displayer.text "$#{@currentScore}"
      @displayer.fadeOut(200, () => @displayer.fadeIn(200))

  getMissedPickupFare: () ->
    @missedPickupFare

  setMissedPickupFare: (v) ->
    @missedPickupFare = v

  getMissedDropFare: () ->
    @missedDropFare

  setMissedDropFare: (v) ->
    @missedDropFare = v

  onMissedPickup: (e) ->
    @currentScore -= @missedPickupFare
    @_refreshScore()

  onMissedDrop: (e) ->
    @currentScore -= @missedDropFare
    @_refreshScore()

  onDrop: (e) ->
    if e.getSpeedRatio() <= @speedRatio
      @currentScore += @bonusTip
    @currentScore += @successfulDropFare
    @_refreshScore()