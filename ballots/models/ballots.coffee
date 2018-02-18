ballotSchema = new SimpleSchema
  _owner:
    type: String
  name:
    type: String
    max: 30
    optional: true
  isPaid:
    type: Boolean
    defaultValue: false
  changeOfCorrectCountSinceLastWinner:
    # May be 0 or 1 depending on whether the last vote made the ballot
    # go up in total winning count.
    type: Number
    defaultValue: 0
#  changeOfRankSinceLastWinner:
#    # May be -1, 0, or 1 depending on whether the last vote made the ballot
#    # go up in rank.
#    type: Number,
#    defaultValue: 0

@Ballots = new Mongo.Collection 'ballots',
  transform: (doc) ->
    doc.owner = Meteor.users.findOne {_id: doc._owner}
    return doc

@Ballots.attachSchema ballotSchema

Ballots.allow
  update: (userId) ->
    user = Meteor.users.findOne {_id: userId}
    return user && user.isAdmin

if Meteor.isServer
  Meteor.publish 'ballots', (_id) ->
    return _id? && Ballots.find({_id: _id}) || Ballots.find({})

if Meteor.isClient
  Meteor.subscribe('ballots')
