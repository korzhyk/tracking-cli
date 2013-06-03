"use strict"

# Services 

# Demonstrate how to register services
# In this case it is a simple value service.
angular.module("socket.io", []).value("version", "0.1").factory "socket", ($rootScope) ->
  socket = io.connect('/')
  on: (eventName, callback) ->
    socket.on eventName, ->
      args = arguments
      $rootScope.$apply ->
        callback.apply socket, args

  emit: (eventName, data, callback) ->
    socket.emit eventName, data, ->
      args = arguments
      $rootScope.$apply ->
        callback.apply socket, args  if callback

