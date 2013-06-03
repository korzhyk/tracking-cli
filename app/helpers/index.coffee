fs = require 'fs'
path = require 'path'
module.exports = (app)->
  # Load helpers
  fs.readdirSync(__dirname).forEach (file)->
    require(path.join(__dirname, file))(app) unless /index/.test file