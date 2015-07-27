# Manages score display. Triggers game over too
class ScoreManager
  constructor: (selector) ->
    @displayer = $(selector)
    @currentScore = 50
    @maxScore = 0
    @nextStep = 300 # Next step before increasing difficulty
    @_refreshScore(true)

    EventBus.get('Zone').register PickupZoneVanishedEvent.NAME, (z) => @onMissedPickup(z)
    EventBus.get('Zone').register DropZoneVanishedEvent.NAME, (z) => @onMissedDrop(z)
    EventBus.get('RideEngine').register DropEvent.NAME, (z) => @onDrop(z)

  _refreshScore: (isIncreasing) ->
    @maxScore = Math.max(@maxScore, @currentScore)
    if @currentScore < 0
      @currentScore = 0
      EventBus.get('ScoreManager').post GameOverEvent.NAME, new GameOverEvent()

    @displayer.text "$#{@currentScore}"
    if isIncreasing
      @displayer.addClass 'increase'
    else
      @displayer.addClass 'decrease'
    @displayer.fadeOut(400, () => @displayer.fadeIn(400))
    setTimeout(
                () => @displayer.removeClass('increase decrease'),
                1200
              )

  getMaxScore: () ->
    @maxScore

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
    @_refreshScore(false)

  onMissedDrop: (e) ->
    @currentScore -= @missedDropFare
    @_refreshScore(false)

  onDrop: (e) ->
    if e.getSpeedRatio() <= @tipSpeedRatio
      @currentScore += @bonusTip
    @currentScore += @successfulDropFare
    @_refreshScore(true)

    if @currentScore >= @nextStep
      # Increase difficulty
      @nextStep *= 2
      EventBus.get('ScoreManager').post IncreaseDifficultyEvent.NAME, new IncreaseDifficultyEvent()