class UserEngine
  constructor: (dest, elementSelector) ->
    @dest = $(dest)
    @elementSelector = elementSelector
    @template = $('#template-user-profile').html()
    Mustache.parse(@template)

    @active = {}
    @activeSize = 0
    @users = []
    id = 0
    for u in USER_SOURCE
      o = u
      o.id = id++
      @users.push o

  showRandom: () ->
    return if @activeSize is @users.length

    id = -1
    while (id < 0) or @active.hasOwnProperty(id)
      id = Math.round(Math.random() * (@users.length - 1))

    u = @users[id]
    @dest.append(Mustache.render(@template, u))
    @active[id] = u
    @activeSize++
    return id


  hide: (id) ->
    @dest.find(@elementSelector).each (i, e) =>
      parsedId = parseInt($(e).data('id'))
      if parsedId is id
        delete @active[id]
        $(e).remove()