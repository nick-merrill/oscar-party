Accounts.onCreateUser (options, user) ->
  user.isApproved = false
  if user.services.facebook
    user.emails = [{address: user.services.facebook.email}]
    user.username = user.emails[0]
    if !user.profile
      user.profile = {}
    user.profile.name = user.services.facebook.name
    logUserAction(user, "Created an account with Facebook.")
  else
    logUserAction(user, "Created an account.")
  return user
