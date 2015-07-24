class ScoreManager
  constructor: (selector) ->
    @displayer = $(selector)
    @currentScore = 0

    EventBus.get('Zone').register PickupZoneVanishedEvent.NAME, (z) => @onMissedPickup(z)
    EventBus.get('Zone').register DropZoneVanishedEvent.NAME, (z) => @onMissedDrop(z)
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

  getSuccessfulDropFare: () ->
    @successfulDropFare

  setSuccessfulDropFare: (v) ->
    @successfulDropFare = v

  getBonusTip: () ->
    @bonusTip

  setBonusTip: (v) ->
    @bonusTip = v

  getTipSpeedRatio: () ->
    @tipSpeedRatio

  setTipSpeedRatio: (v) ->
    @tipSpeedRatio = v

  onMissedPickup: (e) ->
    @currentScore -= @missedPickupFare
    @_refreshScore()

  onMissedDrop: (e) ->
    @currentScore -= @missedDropFare
    @_refreshScore()

  onDrop: (e) ->
    if e.getSpeedRatio() <= @tipSpeedRatio
      @currentScore += @bonusTip
    @currentScore += @successfulDropFare
    @_refreshScore()