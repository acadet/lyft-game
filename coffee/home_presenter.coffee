class HomePresenter
  constructor: () ->

  onStart: () ->
    @userProfileTemplate = $('#template-user-profile').html()
    for u in USERS
      $('.js-user-list').append(Mustache.render(@userProfileTemplate, u))