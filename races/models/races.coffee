contenderSchema = new SimpleSchema
  name:
    type: String
  isWinner:
    type: Boolean
    defaultValue: false
    # Custom validation: If this is a winner, ensure there are no other winners
    # in the same race.
    custom: ->
      if !@value
        # Not a winner, so no need to do anything.
        return true
      # This contender is about to be marked as a winner, so no other
      # contenders can be winners.
      raceContenderMarkedAsWinner = Contenders.findOne
        _race: @field('_race')
        isWinner: true
      console.log(raceContenderMarkedAsWinner)
      if raceContenderMarkedAsWinner?
        # Uses below SimpleSchema.messages error message.
        return "multipleWinnersNotAllowed"
      return true
  _race:
    type: String
  _movie:
    type: String
  _votingBallots:
    type: [String]
    defaultValue: []

SimpleSchema.messages
  multipleWinnersNotAllowed: "Multiple winners are not allowed. Please unset the current winner before setting a new winner."


raceSchema = new SimpleSchema
  name:
    type: String
  order:
    type: Number
    defaultValue: 0
  isVotingClosed:
    type: Boolean
    defaultValue: false
  declaredWinnerAt:
    type: Date
    optional: true
  isNextRace:
    type: Boolean
    defaultValue: false
    custom: ->
      # Allow only one Race with isNextRace set to true.
      if @value == false
        # False isn't a problem.
        return true
      # If true, then check all others to ensure this is the only true value.
      return Races.find({_id: {$ne: @field('_id')}}).count() == 0

@Contenders = new Mongo.Collection 'contenders'
@Races = new Mongo.Collection 'races'
Contenders.attachSchema contenderSchema
Races.attachSchema raceSchema

if Meteor.isServer
  Meteor.publish 'contenders', (_id) ->
    return _id && Contenders.find({_id: _id}) || Contenders.find({})
  Meteor.publish 'races', (_id) ->
    return _id && Races.find({_id: _id}) || Races.find({})

  _userIsAdmin = (userId) ->
    user = Meteor.users.findOne {_id: userId}
    return user? && user.isAdmin

  Races.allow
    insert: (userId, doc) ->
      return _userIsAdmin(userId)
    update: (userId, doc) ->
      return _userIsAdmin(userId)
    remove: (userId, doc) ->
      return _userIsAdmin(userId)

if Meteor.isClient
  Meteor.subscribe('races')
  Meteor.subscribe('contenders')
