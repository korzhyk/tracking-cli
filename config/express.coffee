express    = require 'express'
I18n       = require 'i18n-2'
redisStore = require('connect-redis')(express)
flash      = require 'connect-flash'
helpers    = require './middlewares/helpers'
path       = require 'path'

module.exports = (app, config, passport) ->
  app.set 'showStackError', yes

  app.use express.compress
    filter: (req, res) ->
      /json|text|javascript|css/.test(res.getHeader('Content-Type'))
    level: 9
  
  app.set('views', config.root + '/app/views')
  app.set('view engine', 'jade')

  app.configure ->
    app.use express.responseTime() if app.env is 'development'
    
    I18n.expressBind app,
      extension: '.json'
      directory: config.root + '/public/locales'
      locales: ['en', 'uk']

    app.use express.logger('dev') if app.env is 'development'

    app.use express.favicon(path.join(__dirname, '../public/favicon.ico'))
    app.use express.static(path.join(__dirname, '../public'))
    app.use express.static(path.join(__dirname, '../assets'))
    app.use express.cookieParser()
    app.use express.bodyParser()
    
    # Support for using PUT, DEL etc. in forms using hidden _method field
    app.use express.methodOverride()

    app.use express.session
      secret: 'p8zztgch48rehu79jskhm6aj3'
      key: 'sid'
      store: new redisStore
        client: app.rd
        prefix: 'sess:'
        
    app.use express.csrf()

    app.use flash()
    app.use passport.initialize()
    app.use passport.session()
    app.use helpers(config.app.name)

    app.use app.router



  app.configure 'development', ->
    console.log 'Configuring %s environment', 'development'.debug
    app.use express.errorHandler()
    
    app.locals.pretty = yes
    app.db.set 'debug', yes



  app.configure 'production', ->
    console.log 'Configuring %s environment', 'production'.debug
    # Handle 404
    app.use (req, res) ->
      res.send "404: Page not Found", 404

    # Handle 500
    app.use (error, req, res, next) ->
      res.send "500: Internal Server Error", 500
