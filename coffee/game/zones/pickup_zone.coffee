class PickupZone extends Zone
  constructor: (id, grid, duration) ->
    super(id, grid, duration)

  getColor: () ->
    return @color if @color?

    colorIndex = Math.round(Math.random() * (Zone.COLORS.length - 1))
    @color = Zone.COLORS[colorIndex]
    return @color

  getImgExtension: () ->
    'balloon'

  postVanished: () ->
    EventBus.get('Zone').post(PickupZoneVanishedEvent.NAME, new PickupZoneVanishedEvent(@getId()))