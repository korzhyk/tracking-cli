module.exports = (app, passport, auth) ->
  
  # Passport routes
  require('./routes.passport')(app, passport, auth)

  # Sessions routes
  sessions = require '../app/controllers/sessions'
  app.get '/login', auth.unlessUser, sessions.new
  app.del '/logout', auth.requireUser, sessions.destroy

  # Registrations routes
  registrations = require '../app/controllers/registrations'
  app.get '/signup', auth.unlessUser, registrations.new
  app.post '/signup', auth.unlessUser, registrations.params, registrations.create

  # Account routes
  account = require '../app/controllers/account'
  app.get '/account', auth.requireUser, account.show
  app.get '/account/edit', auth.requireUser, account.edit
  app.del '/account', auth.requireUser, account.destroy

  # Trackers routes
  trackers = require '../app/controllers/trackers'
  app.get '/trackers', auth.requireUser, trackers.index
  app.get '/trackers.json', auth.requireUser, trackers.index_json
  app.post '/trackers', auth.requireUser, trackers.create
  app.get '/trackers/new', auth.requireUser, trackers.new
  app.del '/trackers/:tracker_id', auth.requireUser, trackers.destroy
  app.param 'tracker_id', trackers.load

  # Map routes
  map = require '../app/controllers/map'
  app.get '/map', auth.requireUser, map.index

  # Pages routes
  pages = require '../app/controllers/pages'
  app.get '/', pages.index
