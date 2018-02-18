# On startup, create super user.
adminEmail = Meteor.settings.private.initialAdminCredentials.email
Meteor.startup ->
  if Meteor.users.find().count() == 0
    Accounts.createUser
      username: adminEmail,
      email: adminEmail,
      password: Meteor.settings.private.initialAdminCredentials.password,

  # Set users with superpowers.
  adminUser = Accounts.findUserByEmail(adminEmail)
  Accounts.users.update adminUser._id,
    $set:
      isAdmin: true
      hasSuperpowers: true
