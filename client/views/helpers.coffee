Template.registerHelper 'userEmail', (context) ->
  user = context.hash.user
  if !user
    return ''
  return user.emails[0].address

Template.registerHelper 'owner', (context) ->
  ownerID = context.hash._owner
  return Meteor.users.findOne({_id: ownerID})


Template.registerHelper '$momentCalendar', (date) ->
  m = moment(date)
  return m.calendar()

Template.registerHelper '$momentFullTimeStamp', (date) ->
  m = moment(date)
  return m.format()

Template.registerHelper '$momentTime', (date) ->
  m = moment(date)
  return m.format('h:mma')

Template.registerHelper 'currentPath', ->
  return Router.current().route.path(this)

# Log to console.
Template.registerHelper '$console', (args) ->
  console.log(args)

@$occurredWithinSeconds = (date, seconds) ->
  if !date
    return false
  secondsAgo = moment().subtract(seconds, 'seconds')
  return moment(date).isSameOrAfter(secondsAgo, 'seconds')

Template.registerHelper '$occurredWithinSeconds', (date, seconds) ->
  return $occurredWithinSeconds(date, seconds)

Template.registerHelper 'publicSettings', -> Meteor.settings.public


Meteor.autorun ->
  document.title = Blaze.toHTML(Template.partyName)
