Router.configure
  layoutTemplate: "mainLayout"
  progressSpinner: false
  progressDelay: 100
  notFoundTemplate: 'notFound'

Router.plugin 'dataNotFound', {dataNotFoundTemplate: 'notFound'}
Router.onBeforeAction 'dataNotFound'

Router.onBeforeAction (route) ->
  user = Meteor.user()

  if !Meteor.loggingIn() && !user
    @render 'login'
  else if !Meteor.loggingIn() && user && !(user.profile && user.profile.name)
    @render 'profile'
  else if user && !user.isApproved && route.url != '/accounts/profile'
    @render 'unapproved'
  else
    @next()

Router.route '/accounts/profile', ->
  @render 'profile'

Router.route '/', ->
  Router.go '/nav'

Router.route '/nav', ->
  @render 'nav'

Router.route '/dashboard', ->
  Session.set 'ballotFilterKey', null
  @render 'dashboard'

Router.route '/ballots', ->
  @render 'ballotList',
    data:
      ballots: Ballots.find({})

Router.route '/ballots/mine', ->
  Router.go '/ballots'
  Session.set 'ballotFilterKey', 'mine'

Router.route '/ballots/all', ->
  Router.go '/ballots'
  Session.set 'ballotFilterKey', null

# Shows the status of a cast ballot.
# Ballot owner can choose to edit votes.
Router.route '/ballots/:_id', ->
  ballot = Ballots.findOne({_id: this.params._id})
  if !ballot?
    @render 'notFound'
    return
  @render 'ballot',
    data:
      ballot: ballot

Router.route '/drinkers', ->
  @render 'drinkers'


Router.route '/billing/record', ->
  @render 'recordTransaction'

Router.route '/races', ->
  @render 'races'

Router.route '/races/:_id', ->
  race = Races.findOne @params._id
  if !race
    @render 'notFound'
    return
  @render 'race',
    data:
      race: race

Router.route '/movies', ->
  @render 'movieList'

Router.route '/events', ->
  @render 'events'

Router.route '/settings', ->
  if !Meteor.user().isAdmin
    @render 'accessDenied'
    return
  @render 'settings'