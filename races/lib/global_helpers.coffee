@userCanVoteOnBallot = (user, ballot) ->
  if !user?
    return false
  if !ballot?
    return false
  return user._id == ballot._owner || (user.isAdmin && user.hasSuperpowers)

@logUserAction = (user, msg) ->
  date = moment()
  dateString = date.toDate().toString()
  if user?
    console.log "#{dateString} - #{user.profile && user.profile.name || user._id} (#{user._id}): #{msg}"
  else
    console.log "#{dateString} - #{msg}"
  UserActions.insert
    _user: user?._id
    date: moment().toDate()
    message: msg
