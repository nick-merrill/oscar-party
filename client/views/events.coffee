Template.unapproved.events
  "keyup input#access-code": ->
    $input = $('input#access-code')
    $input.val($input.val().toUpperCase())
    Session.set('accessCode', $input.val())

  "submit form": (e) ->
    e.preventDefault()
    Meteor.call 'verifyAccessCode', Session.get('accessCode'), (error) ->
      if error
        alert error.reason
      else
        Router.go '/ballots/mine'
    return false


Template.topNav.events
  "click .open-help": ->
    Session.set 'helpIsOpen', true
Template.help.events
  "click .close-help": ->
    Session.set 'helpIsOpen', false
