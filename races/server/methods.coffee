Meteor.methods
  deleteContender: (contenderId) ->
    check(contenderId, String)

    user = Meteor.users.findOne {_id: @userId}
    if !user? || !user.isAdmin
      throw new Meteor.Error('unauthorized', "You must be an administrator to delete nominees.")

    Contenders.remove(contenderId)


  addContenderToRace: (raceID, contenderObj) ->
    check(raceID, String)
    check(contenderObj, {
      name: String,
      _movie: String
    })
    user = Meteor.users.findOne {_id: @userId}
    if !user? || !user.isAdmin
      throw new Meteor.Error('unauthorized', "You must be an administrator to add nominees.")

    race = Races.findOne({_id: raceID})
    if !race?
      throw new Meteor.Error('not-found', "Race not found.")

    Contenders.insert(Object.assign({}, contenderObj, {
      _race: race._id
    }))


  setRaceWinner: (raceId, winningContenderId) ->
    check(raceId, String)
    check(winningContenderId, Match.Maybe(String))

    user = Meteor.users.findOne(@userId)
    if !user.isAdmin
      throw new Meteor.Error('unauthorized', "You must be an administrator to set race winners.")

    race = Races.findOne(raceId)
    if !race?
      throw new Meteor.Error("not-found", "Race not found.")

    # Unset other winners.
    logUserAction(user, "Un-set winners for '#{race.name}'.")
    Contenders.update {_race: race._id}, {
      $set: {isWinner: false}
    }, {
      multi: true  # otherwise, only updates one record
    }, (error) ->
      if error
        throw new Meteor.Error(error)
      if !winningContenderId?
        Races.update(race._id, {
          $set: {declaredWinnerAt: null}
        })
        return
      # Set winner if there is one.
      winningContender = Contenders.findOne({
        _id: winningContenderId,
        _race: race._id
      })
      if !winningContender?
        throw new Meteor.Error('not-found', "Invalid winning contender ID for race #{race._id}.")
      logUserAction(user, "Set winner for '#{race.name}' as '#{winningContender.name}'.")
      Contenders.update(winningContender._id, {
        $set: {isWinner: true}
      })
      Races.update(race._id, {
        $set: {declaredWinnerAt: moment().toDate()}
      })
      # Lock the race.
      Meteor.call('changeRaceStatus', race._id, true)

      # Update ballot changes since last winner count.
      ballotIDsMarkingCorrectWinner = winningContender._votingBallots
      Ballots.update {}, {
          $set:
            changeOfCorrectCountSinceLastWinner: 0
        }, {multi: true}
        , ->
          Ballots.update {_id: {$in: ballotIDsMarkingCorrectWinner}}, {
              $inc:
                changeOfCorrectCountSinceLastWinner: 1
            }, {multi: true}

    # Unset next-up race so that this winner will be displayed prominently.
    Meteor.call('setRaceUpNext', null)


  changeRaceStatus: (raceId, shouldClose) ->
    check(raceId, String)
    check(shouldClose, Boolean)

    user = Meteor.users.findOne {_id: @userId}
    if !user.isAdmin
      throw new Meteor.Error('unauthorized', "You must be an administrator to change a race's status.")

    race = Races.findOne {_id: raceId}

    logUserAction user, "Change race '#{race.name}' closed status to '#{shouldClose}'."
    Races.update {_id: race._id},
      $set:
        isVotingClosed: shouldClose


  setRaceUpNext: (raceId) ->
    check(raceId, Match.Maybe(String))

    Races.update {},
      $set:
        isNextRace: false
      , {multi:true}
      , (error) ->
        if error?
          throw error
        Races.update raceId,
          $set:
            isNextRace: true


  makeBallotVote: (ballotId, raceId, contenderId) ->
    check(ballotId, String)
    check(raceId, String)
    check(contenderId, String)

    ballot = Ballots.findOne ballotId
    race = Races.findOne raceId
    contender = Contenders.findOne({
      _id: contenderId,
      # Use race here to make sure that we're talking about the right contender.
      _race: race._id
    })

    user = Meteor.users.findOne @userId

    if !ballot?
      throw new Meteor.Error 'ballot-not-found', "Could not find that ballot"

    if !userCanVoteOnBallot(user, ballot)
      throw new Meteor.Error 'unauthorized', "You are not allowed to vote on this ballot."

    if !race?
      throw new Meteor.Error 'race-not-found', "Could not find that race."

    if race.isVotingClosed and !user.isAdmin
      throw new Meteor.Error 'race-voting-closed', "Votes for #{race.name} are no longer being accepted."

    if !contender?
      throw new Meteor.Error 'contender-not-found', "Could not find that nominee for that race."

    logUserAction user, "Casting vote for '#{race.name}': '#{contender.name}'."

    # Removes ballot's vote from other contenders and adds it to specified contender.
    Contenders.update({
      _race: race._id
    }, {
      $pull:
        _votingBallots: ballot._id
    }, (error) ->
      if error
        throw new Meteor.Error('error', "Could not remove votes from other nominees.")
      # Add vote to specified contender.
      Contenders.update({
        _race: race._id,
        _id: contender._id
      }, {
        $addToSet:
          _votingBallots: ballot._id
      })
    )
