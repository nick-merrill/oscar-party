if Meteor.isServer
  Meteor.users.allow
    update: (userId, doc, fieldNames) ->
      if !userId
        return false
      user = Meteor.users.findOne {_id: userId}
      # Admins can edit anyone.
      if user.isAdmin
        return true
      if "isApproved" in fieldNames
        return false  # only admins can edit this
      return userId == doc._id

  Meteor.publish 'users', ->
    return Meteor.users.find({})


if Meteor.isClient
  Meteor.subscribe('users')