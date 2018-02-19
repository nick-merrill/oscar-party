# On startup, create super user.
adminEmail = Meteor.settings.private.initialAdminCredentials.email
Meteor.startup ->
  if Meteor.users.find().count() == 0
    userId = Accounts.createUser
      username: adminEmail
      email: adminEmail
      password: Meteor.settings.private.initialAdminCredentials.password
    # Set users with superpowers.
    Accounts.users.update userId,
      $set:
        isAdmin: true
        hasSuperpowers: true

# Configure services
for service in Meteor.settings.private.services
  serviceName = service.service
  ret = ServiceConfiguration.configurations.upsert(
    { service: serviceName },
    {$set: _.omit(service, 'service')}
  )
