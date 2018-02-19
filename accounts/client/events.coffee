Template.mainLayout.events
  'click .log-out': ->
    Meteor.logout()
    Router.go '/'

Template.profile.events
  "click #submit, submit form": (e) ->
    e.preventDefault()
    $body = $(e.target).closest('body')
    name = $body.find('input#name').val()
    email = $body.find('input#email').val()
    oldPassword = $body.find('input#old-password').val()
    newPassword = $body.find('input#new-password').val()

    if !name
      alert "Please provide a name so we know when you win!"
      return
    if !email
      alert "Please provide an email in order to log in again."
      return
    email = email.toLowerCase()

    Meteor.users.update {_id: Meteor.user()._id},
      $set:
        profile:
          name: name
        emails: [{address: email}]

    _success = ->
      Router.go '/'

    if $('input#desire-password-change').prop('checked')
      Accounts.changePassword oldPassword, newPassword, (error) ->
        if error
          alert error.reason
          return
        else
          _success()
    else
      _success()

    return false

  "change input#desire-password-change": (e) ->
    $checkbox = $(e.target)
    $changePasswordSection = $('.change-password')
    if $checkbox.prop('checked')
      $changePasswordSection.show()
    else
      $changePasswordSection.hide()

  "click #logout": (e) ->
    Meteor.logout ->
      Router.go '/'

Template.login.events
  'click button#fb-login': (e) ->
    Meteor.loginWithFacebook
      requestPermissions: ['public_profile', 'email']
    , (error) ->
      if error
        console.log(error)
        throw new Meteor.Error("There was a problem logging in with Facebook.")

  'keyup input, click #submit': (e) ->
    $email = $('input#email')
    $password = $('input#password')

    if (e.type == 'keyup' && e.which != 13)
      return

    email = $email.val()
    password = $password.val()
    if !email || '@' not in email
      Session.set 'loginErrorText', "Please enter a valid email address."
      $email.focus()
      return
    email = email.toLowerCase()
    if !password
      Session.set 'loginErrorText', "You must enter a password."
      $password.focus()
      return

    # Try to log in with this information.
    Meteor.loginWithPassword {email: email}, password, (error) ->

      # Call this when ready to redirect away from successful login.
      continueHome = ->
        Session.set 'loginErrorText', null
        Router.go '/ballots/mine'

      if !error
        continueHome()
        return
      # Error logging in, so try to create account with this information.
      Accounts.createUser
        email: email
        password: password
      , (error) ->
        if error
          console.error error
          reason = error.reason
          if reason == 'Email already exists.'
            reason = error.reason + " But that account has a different password. Try a different password."
          Session.set 'loginErrorText', reason
        else
          continueHome()
