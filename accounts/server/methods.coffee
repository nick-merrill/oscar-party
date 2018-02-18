Meteor.methods
  sendVerificationEmail: ->
    if !@userId
      throw new Meteor.Error "not-logged-in", "Must be logged in to send verification email"

    user = Meteor.users.findOne {_id: @userId}
    email = user.emails[0].address

    if !user.emails[0].verified
      Accounts.sendVerificationEmail(@userId, email)
      return "verification email sent"
    else
      throw new Meteor.Error "already-verified", "Your email (#{email}) has already been verified"


  verifyAccessCode: (code) ->
    check(code, String)
    if !@userId
      throw new Meteor.Error 'not-logged-in', "Must be logged in to verify an access code."

    user = Meteor.users.findOne {_id: @userId}

    if code.toUpperCase() == Meteor.settings.private.accessCode
      Meteor.users.update {_id: @userId},
        $set:
          isApproved: true
      logUserAction user, "Entered valid access code. (Account validated.)"
      return true

    logUserAction user, "Entered in-valid access code!"

    throw new Meteor.Error 'invalid-access-code', "That access code (\"#{code}\") is invalid. Please try again."

