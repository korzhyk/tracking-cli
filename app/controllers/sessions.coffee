#
# Module dependencies
#
mongoose = require 'mongoose'
_ = require 'lodash'

#
# Show login form
#
exports.new = (req, res) ->
  res.render 'sessions/new'

#
# Logout
#
exports.destroy = (req, res) ->
  req.flash 'notice', 'Log out!'
  req.logout()
  res.redirect '/'