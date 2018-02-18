Template.events.helpers
  userActions: ->
    userActions = UserActions.find({}, {
      sort: [['date', 'desc']]
      limit: 200
      transform: (doc) ->
        doc.user = Meteor.users.findOne doc._user
        return doc
    })
    return userActions
