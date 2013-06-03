mongoose = require 'mongoose'
moment = require 'moment'
_ = require 'lodash'


env      = process.env.NODE_ENV or 'development'

# Configure
config = require("../../config/environment")[env]

pg = require 'pg'
pg_client = new pg.Client(config.postgres)
pg_client.connect()

# SELECT_POINTS_FOR_TRACKER = "
# SELECT row_to_json(fc)
#   FROM (
#     SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
#       FROM (
#         SELECT 'Feature' As type
#           , ST_AsGeoJSON(lg.geom)::json As geometry
#           , row_to_json((
#               SELECT l FROM (SELECT date, speed, direction, fuel) As l
#             )) As properties
#           FROM points WHERE tracker_id = $1 LIMIT $2 As lg
#       ) As f
#   ) As fc;
# "

SELECT_POINTS_FOR_TRACKER = "
SELECT 'Feature' as type 
  , ST_AsGeoJSON(geom)::json As geometry
  , row_to_json((
      SELECT l FROM (SELECT tracker_id, date, speed, direction, fuel, status) As l
    )) As properties
  FROM points WHERE tracker_id = $1 AND date BETWEEN $2 AND $3 ORDER BY date DESC;
"

SELECT_LAST_POINTS_FOR_TRACKER = "
SELECT 'Feature' as type 
  , ST_AsGeoJSON(geom)::json As geometry
  , row_to_json((
      SELECT l FROM (SELECT tracker_id, date, speed, direction, fuel, status) As l
    )) As properties
  FROM points WHERE tracker_id = $1 ORDER BY date DESC LIMIT $2;
"

exports.list = (opts, cb)->

  if typeof opts is 'function'
    cb = opts
    opts = {}

  opts.from ?= moment().startOf('day')
  opts.to ?= moment().endOf('day')

  Tracker = mongoose.model 'Tracker'
  Tracker.find().lean().exec (err, trackers)->
    res = []
    for t in trackers
      pg_client.query SELECT_POINTS_FOR_TRACKER, ["#{t._id}", opts.from, opts.to], cb

exports.lastPoints = (opts, cb)->
  if typeof opts is 'function'
    cb = opts
    opts = {}

  opts.limit ?= 100

  pg_client.query SELECT_LAST_POINTS_FOR_TRACKER, [opts.tracker_id, opts.limit], cb
