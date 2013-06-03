_ = require 'lodash'
Point = require '../models/point'

module.exports = (app, sio)->

  rd = app.rd_sub
  rd.subscribe "live:point"

  sio.sockets.on "connection", (socket) ->

    socket.on 'get:points', (opts)->
      Point.list opts, (err, points) ->
        socket.emit 'points',
          tracker_id: opts.tracker_id
          data: points?.rows or []

    socket.on 'get:last:points', (opts)->
      Point.lastPoints opts, (err, points) ->
        console.log err, points
        socket.emit 'last:points',
          tracker_id: opts.tracker_id
          data: points?.rows or []


    rd.on "message", (chanel, msg)->
      obj = JSON.parse msg
      socket.emit 'live:point',
        tracker_id: obj.tracker_id
        data: obj.data

    socket.on "disconnect", ->
