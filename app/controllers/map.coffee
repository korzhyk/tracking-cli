mongoose = require 'mongoose'
_ = require 'lodash'

exports.index = (req, res)->
  res.render 'map/index'