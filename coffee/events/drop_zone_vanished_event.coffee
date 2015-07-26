class DropZoneVanishedEvent
  @NAME = 'DropZoneVanishedEvent'

  constructor: (id) ->
    @id = id

  getId: () ->
    @id