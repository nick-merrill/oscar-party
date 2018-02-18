@UserActions = new Mongo.Collection 'userActions'

if Meteor.isServer
  Meteor.publish 'userActions', (_id) ->
    user = Meteor.user()
    if !user || !user.isAdmin
      return []
    if _id?
      return UserActions.find(_id)
    return UserActions.find({})
if Meteor.isClient
  Meteor.subscribe('userActions')
