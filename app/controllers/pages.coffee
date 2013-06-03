#
# Module dependencies
#
mongoose = require 'mongoose'
_ = require 'lodash'

#
# Index page
#
exports.index = (req, res) ->
  res.render 'pages/index'
