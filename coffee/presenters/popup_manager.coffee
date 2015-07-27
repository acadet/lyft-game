# Manages start and end pop ups
class PopupManager
  constructor: () ->
    @wrapper = $('.js-popup-wrapper')
    @startPopup = $('.js-starting-popup')
    @endPopup = $('.js-ending-popup')

    @startPopup.find('.js-confirmation').first().on 'click', () => @onConfirmation()

  _showWrapper: () ->
    @wrapper.removeClass 'hidden'
    @wrapper.css 'opacity', 0
    @wrapper.animate({ opacity: 1 }, 1000)

  _showPopup: (popup) ->
    $(popup).css
      top: (@wrapper.outerHeight() - $(popup).outerHeight()) / 2
      left: (@wrapper.outerWidth() - $(popup).outerWidth()) / 2
    popup.children().each (i, e) =>
      $(e).css('opacity', 0)
    popup.show 'puff', null, 1000, () =>
      popup.children().each (i, e) => $(e).animate({ opacity: 1 }, 250)

  showStart: () ->
    @_showWrapper()
    @_showPopup(@startPopup)

  showEnding: (duration, maxBalance) ->
    inMinutes = Math.round(duration / 1000 / 60)
    content = " #{inMinutes} minute"
    content += "s" if inMinutes > 1
    content = " less than a minute" if inMinutes < 1

    @_showWrapper()
    @endPopup.find('.js-game-countdown').first().append(content)
    @endPopup.find('.js-game-max-balance').first().append(maxBalance)
    @_showPopup(@endPopup)

  onConfirmation: () ->
    @startPopup.remove()
    @wrapper.addClass 'hidden'
    EventBus.getDefault().post(StartEvent.NAME, new StartEvent())