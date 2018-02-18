userHasName = ->
  return !!(Meteor.user()?.profile?.name)

Template.profile.helpers
  nameClass: ->
    if !userHasName()
      return "text-danger"
  nameMessage: ->
    if !userHasName()
      return "Please provide your name so we know who gets all the money when you win!"
