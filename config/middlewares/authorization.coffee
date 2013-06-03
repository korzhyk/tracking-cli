i18n = require 'i18n-2'
#
# Generic require login routing middleware
#

exports.requireUser = (req, res, next) ->
  unless req.isAuthenticated()
    req.session.return_to = req.url
    return res.redirect '/login'
  next()

exports.unlessUser = (req, res, next)->
  if req.isAuthenticated()
    console.log req
    req.flash 'notice', req.i18n.__('You logged in now!')
    return res.redirect '/'
  next()