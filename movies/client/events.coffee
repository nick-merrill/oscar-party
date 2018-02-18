Template.addMovie.events
  'submit form': (e) ->
    e.preventDefault()

    $name = $('input#name')
    $youtubeID = $('input#trailer_URL')

    name = $name.val()
    youtubeID = $youtubeID.val()

    if !name
      alert 'Please provide a name for the movie.'
      return

    Meteor.call 'addMovie', {
      name,
      youtubeID
    }, (error) ->
      if error
        alert error.message
        return
      $name.val('')
      $youtubeID.val('')

    return false
