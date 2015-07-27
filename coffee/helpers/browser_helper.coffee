class BrowserHelper
  @isFirefox: () ->
    /mozilla/.test(navigator.userAgent.toLowerCase()) and !/webkit/.test(navigator.userAgent.toLowerCase())