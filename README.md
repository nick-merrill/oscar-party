# Oscar

## How Tos

### Empower admins

    Meteor.users.update({_id: ID_OF_USER}, {$set: {isAdmin: true}})

### Give admins superpowers

This allows admins to:
* View and modify votes from **any** user.

    Meteor.users.update({_id: ID_OF_USER}, {$set: {hasSuperpowers: true}})
