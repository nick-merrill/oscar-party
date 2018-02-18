Accounts.onCreateUser (options, user) ->
  user.isApproved = false
  Email.send
    from: Meteor.settings.private.senderEmail
    to: Meteor.settings.private.adminEmail
    subject: "New Oscar User: #{user.emails[0].address}"
    text: EJSON.stringify(user)
  return user
