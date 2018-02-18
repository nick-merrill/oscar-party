@ballotNumberCorrectVotes = (ballot) ->
  wins = 0
  for race in Races.find({}).fetch()
    votedContender = ballotVote(ballot, race)
    if votedContender && votedContender.isWinner
      wins++
  return wins

Template.registerHelper 'ballotNumberCorrectVotes', (ballot) ->
  return ballotNumberCorrectVotes(ballot)

# Returns the contender for which the ballot voted, if there is a vote.
ballotVote = (ballot, race) ->
  if !ballot? || !race?
    return null
  return Contenders.findOne({
    _race: race._id,
    _votingBallots: ballot._id
  })

voteStatusKey = (ballot, race) ->
  winningContender = winningRaceContender(race)
  votedContender = ballotVote(ballot, race)
  if votedContender? && winningContender?
    return votedContender._id == winningContender._id && 'win' || 'loss'
  return null

Template.ballot.helpers
  panelClasses: (ballot, race) ->
    switch voteStatusKey(ballot, race)
      when 'win' then return 'panel-success'
      when 'loss' then return 'panel-danger'
      else
        if ballotVote(ballot, race)
          return 'panel-primary'
        else
          return 'panel-default'
  panelIconClasses: (ballot, race) ->
    switch voteStatusKey(ballot, race)
      when 'win' then return 'fa fa-smile-o'
      when 'loss' then return 'fa fa-frown-o'
      else ''

Template.registerHelper 'ballotVote', (ballot, race) ->
  return ballotVote(ballot, race)

Template.registerHelper 'ballotVoteEquals', (ballot, race, contender) ->
  votedContender = ballotVote(ballot, race)
  return votedContender && votedContender._id == contender._id

Template.registerHelper 'shouldDrawAttentionToBallot', (ballot) ->
  latestDeclarationTime = latestRaceInfo()?.race?.declaredWinnerAt
  if !latestDeclarationTime
    return false
  return (
    ballot.changeOfCorrectCountSinceLastWinner > 0 &&
      $occurredWithinSeconds(latestDeclarationTime, 20)
  )


# Ballot is complete if all races have been voted on.
ballotIsComplete = (ballot) ->
  for race in Races.find({}).fetch()
    if !ballotVote(ballot, race)?
      return false
  return true

Template.registerHelper 'ballotStatus', (ballot) ->
  if !ballotIsComplete(ballot)
    html = "<span class='text-danger'>&mdash; Incomplete Ballot #{ballot.isPaid && '<span class="text-success">(paid)</span>' || '(unpaid)'} &mdash;</span>"
  else if !ballot.isPaid
    html = '''<span class='text-danger'>&mdash; Unpaid / Inactive Ballot &mdash;</span>'''
  else
    html = '''<span class='text-success'><i class="fa fa-certificate"></i> Activated Ballot</span>'''
  return new Spacebars.SafeString(html)

Template.registerHelper 'allBallots', (active) ->
  query = {}
  if active == true
    query.isPaid = true
  ballots = Ballots.find(query).fetch()
  ballots = _.sortBy ballots, (ballot) ->
    ballot.numberCorrectVotes = ballotNumberCorrectVotes(ballot)
    return -ballot.numberCorrectVotes
  rank = 0
  previousBallot = null
  for ballot in ballots
    if !ballot.isPaid
      ballot.rank = null
      continue
    if !previousBallot? || previousBallot.numberCorrectVotes != ballot.numberCorrectVotes
      rank++
    ballot.rank = rank
    previousBallot = ballot
  return ballots

Template.registerHelper 'userCanVoteOnBallot', (ballot) ->
  return userCanVoteOnBallot(Meteor.user(), ballot)

Template.registerHelper 'userCanSetVoteOnRace', (ballot, race) ->
  user = Meteor.user()
  if !user
    return false
  return user.isAdmin || userCanVoteOnBallot(user, ballot) && !race.isVotingClosed

Template.registerHelper 'userCanViewBallotRace', (ballot, race) ->
  user = Meteor.user()
  return userCanVoteOnBallot(user, ballot) || race.isVotingClosed


Template.ballotList.helpers
  shouldDisplayBallot: (ballot, shouldHideUnpaid) ->
    if shouldHideUnpaid && !ballot.isPaid
      return false
    isMyBallot = ->
      return ballot._owner == Meteor.userId()
    if Session.equals('ballotFilterKey', 'mine')
      isMyBallot()
    else
      return true
