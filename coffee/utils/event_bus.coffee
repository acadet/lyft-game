class EventBus
  @BUSES = {}

  constructor: (name) ->
    @name = name
    @listeners = {}

  register: (name, callback) ->
    if @listeners.hasOwnProperty(name)
      @listeners[name].push(callback)
    else
      @listeners[name] = [callback]

  post: (name, data) ->
    return unless @listeners.hasOwnProperty(name)

    for l in @listeners[name]
      l(data)

  @getDefault: () ->
    return EventBus.get('default')

  @get: (name) ->
    if not EventBus.BUSES.hasOwnProperty(name)
      b = new EventBus(name)
      EventBus.BUSES[name] = b
    return EventBus.BUSES[name]