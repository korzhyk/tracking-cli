
#
# Global template helpers
#
module.exports = (app) ->

  #
  # Inspect for views
  #
  util = require 'util'
  app.locals.inspect = util.inspect
  
  #
  # Template function for Markdown rendering
  #
  marked = require 'marked'
  app.locals.marked = marked
  
  #
  # Named date parsing functions
  #
  moment = require 'moment'

  app.locals.time_ago = (date) ->
    moment(date).fromNow()

  app.locals.format_date = (date, format)->
    format ?= 'D MMMM YYYY'
    moment(date).format(format)