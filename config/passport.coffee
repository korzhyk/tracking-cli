mongoose = require 'mongoose'
User = mongoose.model('User')

module.exports = (passport) ->

  LocalStrategy = require('passport-local').Strategy

  # Serialize sessions
  passport.serializeUser (user, done) ->
    createAccessToken = ->
      user.generateRandomToken (err, token)->
        User.findOne
          access_token: token
        , (err, existingUser) ->
          return done(err)  if err
          if existingUser
            createAccessToken() # Run the function again - the token has to be unique!
          else
            user.set "access_token", token
            user.save (err) ->
              return done(err)  if err
              done null, user.get("access_token")

    createAccessToken()  if user._id
  
  passport.deserializeUser (token, done) ->
    User.findOne access_token: token, (err, user)->
      done(null, user)

  # Define the local auth strategy
  passport.use new LocalStrategy (login, password, done) ->
    User.findOne $or: [{username: login}, {email: login}], (err, user) ->
      if err
        return done err
      if !user
        return done null, false, message: 'Unknown user'
      
      user.comparePassword password, (err, isMatch) ->
        if err
          return done err
        if isMatch
          return done null, user
        else
          return done null, false, message: 'Invalid password'
