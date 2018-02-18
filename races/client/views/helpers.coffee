@winningRaceContender = (race) ->
  return Contenders.findOne({
    _race: race._id,
    isWinner: true
  })

Template.registerHelper 'raceHasWinner', (race) ->
  return winningRaceContender(race)?

Template.registerHelper 'totalRaceCount', ->
  return Races.find({}).count()
Template.registerHelper 'totalDeclaredRaceCount', ->
  return Races.find({declaredWinnerAt: {$not: null}}).count()


Template.registerHelper 'races', ->
  return Races.find({}, {sort: [
    ['isNextRace', 'desc'],          # Put the next-up race first,
    ['declaredWinnerAt', 'desc'],  # then the latest declared winners,
    ['order', 'asc'],              # then sort by order number,
    ['name', 'asc']                # and name.
  ]})

Template.registerHelper 'movies', ->
  return Movies.find({}, {sort: [['name', 'asc']]})

Template.registerHelper 'getContenders', (raceID) ->
  contenders = Contenders.find({_race: raceID}, {sort: [['name', 'asc']]}).fetch()
  # Extend contenders with their movies.
  return _.map contenders, (c) -> Object.assign({}, c, {
    movie: Movies.findOne(c._movie)
  })

Template.raceTile.helpers
  shouldDisplayOrdering: (mini) ->
    user = Meteor.user()
    return !mini && user && user.isAdmin
