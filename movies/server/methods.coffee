Meteor.methods
  addMovie: (doc) ->
    check(doc, {
      name: String,
      youtubeID: Match.Maybe(String)
    })
    if !Meteor.user().isAdmin
      throw new Meteor.Error('user-not-admin', "Admin rights required to add a movie.")
    Movies.insert doc, (error) ->
      if error
        throw new Meteor.Error('server-error', error.message)
