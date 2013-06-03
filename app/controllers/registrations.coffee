#
# Module dependencies
#
mongoose = require 'mongoose'
_ = require 'lodash'

User = mongoose.model 'User'

#
# Show form for register
#
exports.new = (req, res)->
  user = new User(req.body.User)
  res.render 'registrations/new', user: user

#
# Register new user
#
exports.create = (req, res) ->
  user = new User(req.body.User)
  user.save (err) ->
    if err
      return res.render 'registrations/new', user: user
    req.login user, (err)->
      res.redirect '/'

#
# Sanitize params
#
exports.params = (req, res, next)->
  paramsUser = req.body.User
  params = {}
  if paramsUser
    ['fullname', 'email', 'username', 'password', 'password_confirmation'].forEach (param)->
      params[param] = paramsUser[param] if paramsUser[param]
  req.body.User = params
  next()

