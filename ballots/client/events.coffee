Template.ballotList.events
  "click #select-all": ->
    Session.set 'ballotFilterKey', null
  "click #select-mine": ->
    Session.set 'ballotFilterKey', 'mine'

  "click #new-ballot": ->
    Meteor.call 'createBallot', null, (error, ballotId) ->
      Router.go "/ballots/#{ballotId}"

Template.ballot.events
  'click #change-payment-status': (e, template) ->
    ballot = template.data.ballot
    isPaid = !ballot.isPaid
    Ballots.update {_id: ballot._id}, {$set: {isPaid: isPaid}}, (error) ->
      if error
        toastr.error error.reason
      else
        toastr.success "Ballot marked as #{isPaid && 'PAID' || 'OWED'}."
