@latestRaceInfo = ->
  ret = {}
  race = Races.findOne
    declaredWinnerAt: {$exists: true}
  , {sort: [['declaredWinnerAt', 'desc']]}
  if !race
    return ret
  ret.race = race
  winningContender = winningRaceContender(race)
  if !winningContender
    return ret
  ret.winningContender = winningContender
  ret.ballotIDsVotedForWinner = winningContender._votingBallots
  return ret

@ballotsByFilter = (options) ->
  if options.latestWasVictorious?
    {race, winningContender, ballotIDsVotedForWinner} = latestRaceInfo()
    if !race || !winningContender
      return []
    if options.latestWasVictorious
      return Ballots.find {_id: {$in: ballotIDsVotedForWinner}}
    else
      return Ballots.find {_id: {$not: {$in: ballotIDsVotedForWinner}}}
  return []

Template.drinkers.helpers
  latestRace: -> latestRaceInfo().race
  latestWinningContender: ->
    ret = latestRaceInfo().winningContender
    if ret
      ret.movie = Movies.findOne ret._movie
    return ret
  latestLoserBallots: -> ballotsByFilter({latestWasVictorious: false})
  latestWinnerBallots: -> ballotsByFilter({latestWasVictorious: true})
