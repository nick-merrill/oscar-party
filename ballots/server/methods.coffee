Meteor.methods
  createBallot: (name) ->
    userId = @userId
    user = Meteor.users.findOne {_id: userId}
    userBallots = Ballots.find({_owner: userId}).fetch()
    highestNum = 0
    if !name?
      for ballot in userBallots
        if ballot.name && ballot.name.match("#[0-9]+")
          thisNum = parseInt(ballot.name.substr(1))
          if thisNum > highestNum
            highestNum = thisNum
      name = "#" + (highestNum + 1)
    ballotId = Ballots.insert
      name: name
      _owner: userId

    logUserAction user, "Created ballot '#{ballotId}'"

    return ballotId
