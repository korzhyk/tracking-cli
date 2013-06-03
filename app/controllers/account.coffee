i18n = require 'i18n-2'
#
# Module dependencies
#
mongoose = require 'mongoose'
_ = require 'lodash'


exports.show = (req, res)->
  res.render 'account/show'

exports.edit = (req, res)->
  res.render 'account/edit'

exports.destroy = (req, res)->
  if req.body.IKnowWhatIDoing
    req.user.comparePassword req.body.password, (isMatch)->
      if isMatch
        req.user.remove (err)->
          return res.redirect '/account/edit#destroy' if err
          req.flash 'notice', req.i18n.__ "Dear %s, your account was destroyed!", req.user.name.first
          req.logout()
          res.redirect '/'
      else
        req.flash 'error', req.i18n.__ "Password does't match!"
        res.redirect '/account/edit#destroy'
  else
    req.flash 'error', req.i18n.__ 'You must provide password for delete your account!'
    res.redirect '/account/edit#destroy'