Template.addRace.events
  "submit form": (e) ->
    e.preventDefault()

    $form = $(e.target).closest('form')
    $name = $form.find('input#name')
    name = $name.val()
    Races.insert
      name: name

    $name.val('')

    return false

Template.addNominee.events
  # Auto-set name to the movie name to save time.
  "change #movie_id": (e) ->
    # Don't auto-set if name is already set.
    $name = $('#name')
    if $name.val()
      return
    movieId = $("#movie_id").val()
    movie = Movies.findOne movieId
    $name.val(movie.name)

  "submit form": (e, template) ->
    e.preventDefault()

    $form = $(e.target).closest('form')
    $name = $form.find('input#name')
    $movieID = $form.find('select#movie_id')
    name = $name.val()
    movieID = $movieID.val()
    if !name
      alert "Please provide a name for the new nominee."
      return false
    if !movieID
      alert "Please provide a movie for the new nominee."
      return false

    race = template.data.race

    Meteor.call('addContenderToRace', race._id, {
      name,
      _movie: movieID,
    })

    $name.val('')
    $movieID.val('')

    return false


Template.races.events
  "keyup input.race-order": (e, template) ->
    if e.which != 13
      return
    order = parseInt($(e.target).val())
    if _.isNaN(order)
      toastr.error "Please type number!"
      return
    Races.update {_id: @._id},
      $set:
        order: order
    toastr.success "Order was updated"

  "click .up-next-button": (e, template) ->
    $button = $(e.target).closest('.up-next-button')
    raceID = $button.data('race-id')
    Meteor.call('setRaceUpNext', raceID)


Template.race.events
  "click .select-winner": (e, template) ->
    contender = this
    race = template.data.race
    Meteor.call "setRaceWinner", race._id, contender._id

  "click .deselect-winner": (e, template) ->
    race = template.data.race
    Meteor.call "setRaceWinner", race._id, null

  "click .delete": (e, template) ->
    contender = this
    if confirm "Are you sure you want to delete the nomination for #{contender.name}? This could have unintended consequences!"
      Meteor.call('deleteContender', contender._id)

  "click #delete-race": (e, template) ->
    race = template.data.race
    if confirm "Are you sure you want to delete the \"#{race.name}\" nomination category?"
      Races.remove {_id: race._id}, (error) ->
        if error
          alert error
        else
          Router.go '/races'

  "click .change-race-status": (e, template) ->
    race = template.data.race
    Meteor.call 'changeRaceStatus', race._id, !race.isVotingClosed, (error) ->
      if error
        toastr.error error.reason
      else
        toastr.success "Voting is now #{!race.isVotingClosed && 'LOCKED' || 'UNLOCKED'}."


Template.contender.events
  'click .contender-vote-button': (e, template) ->
    data = template.data
    if !data.ballot || !data.race || !data.contender
      return
    makeVote = ->
      Meteor.call 'makeBallotVote', data.ballot._id, data.race._id, data.contender._id, (error) ->
        if error
          toastr.error error.reason
        else
          toastr.success "Vote for #{data.race.name} recorded"

    if data.race.isVotingClosed
      if confirm "Voting for #{data.race.name} is closed. Do you wish to override the lock?"
        makeVote()
    else
      makeVote()
