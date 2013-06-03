require './config/extends'

###
Form5 Node.js Express Skeleton
Based on https://github.com/madhums/nodejs-express-mongoose-demo
###
coffee   = require 'coffee-script'
express  = require 'express'
http     = require 'http'
fs       = require 'fs'
colors   = require './config/colors'
passport = require 'passport'
mongoose = require 'mongoose'
redis    = require 'redis'
pg       = require 'pg'
io       = require 'socket.io'
less     = require 'less'
env      = process.env.NODE_ENV or 'development'

# Configure
config = require("./config/environment")[env]
auth = require("./config/middlewares/authorization")

# Define App
app = express()
app.env = env

# Bootstrap mongodb database
console.log "Connecting to %s at %s", 'MongoDB'.info, config.mongodb.debug
mongoose.connect(config.mongodb)
mongoose.connection.on 'error', (msg)-> console.log "Mongoose: %s".error, msg.to_s.error
app.db = mongoose

# Bootstrap redis database
console.log "Connecting to %s at %s:%s", 'Redis'.info, config.redis.host.debug, config.redis.port.to_s.debug
rd_sub = redis.createClient()
            .on 'error', (msg)-> console.log "Redis SUB: %s".error, msg.to_s.error
app.rd_sub = rd_sub
rd_pub = redis.createClient()
            .on 'error', (msg)-> console.log "Redis PUB: %s".error, msg.to_s.error
app.rd_pub = rd_pub

# Bootstrap PostGIS database
console.log "Connecting to %s at %s", 'PostGIS'.info, config.postgres.debug
pg_client = new pg.Client(config.postgres)
pg_client.connect (msg)-> console.log "Postgres: %s", msg.to_s.error if msg
app.pg = pg_client

# Bootstrap models
models_path = __dirname + "/app/models"
fs.readdirSync(models_path).forEach (file)->
  require models_path + "/" + file

# bootstrap passport config
require("./config/passport") passport, config

# express settings
require("./config/express") app, config, passport

# Bootstrap routes
require("./config/routes") app, passport, auth

# Helper funtions
require("./app/helpers") app

# Start the app by listening on <port>
port = process.env.PORT or 3000
server = http.createServer(app)
server.listen port, '127.0.0.1', ->
  console.log "Tracking app running on port %s", port.to_s.debug

sio = io.listen(server)
# Bootstrap sockets
sockets_path = __dirname + "/app/sockets"
fs.readdirSync(sockets_path).forEach (file)->
  require(sockets_path + "/" + file)(app, sio)
