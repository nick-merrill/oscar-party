moviesSchema = new SimpleSchema
  name:
    type: String
    unique: true
  youtubeID:
    type: String
    unique: true
    optional: true

@Movies = new Mongo.Collection 'movies'

@Movies.attachSchema moviesSchema

_userIsAdmin = (userId) ->
  user = Meteor.users.findOne {_id: userId}
  return user? && user.isAdmin

# Note: No Mongo methods allowed for Movies. Must call a server method.
# This is inspired by Meteor's recommendation at https://guide.meteor.com/security.html#allow-deny

if Meteor.isServer
  Meteor.publish 'movies', (_id) ->
    return _id? && Movies.find({_id: _id}) || Movies.find({})

if Meteor.isClient
  Meteor.subscribe 'movies'
