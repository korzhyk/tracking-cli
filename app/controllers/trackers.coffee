mongoose = require 'mongoose'
_ = require 'lodash'

Tracker = mongoose.model 'Tracker'

#
# New article form
#
exports.new = (req, res) ->
  res.render 'trackers/new',
    tracker: new Tracker()


#
# Create new article
#
exports.create = (req, res) ->
  req.body.Tracker.user = req.user
  tracker = new Tracker req.body.Tracker
  tracker.save (err) ->
    if err
      console.log err
      return res.render 'trackers/new',
        tracker: tracker
    res.redirect '/trackers'

exports.show = (req, res) ->
  tracker = req.tracker
  res.render 'trackes/show', tracker: tracker

#
# Tracker edit form
#
exports.edit = (req, res) ->
  tracker = req.tracker
  res.render 'trackers/edit',
    tracker: tracker

#
# Update article
#
exports.update = (req, res) ->
  tracker = req.tracker
  
  tracker = _.extend tracker, req.body.Tracker
  tracker.save (err) ->
    if err
      res.render 'trackers/edit',
        tracker: tracker
    else
      req.flash 'notice', tracker.name + ' was successfully updated.'
      res.redirect '/trackers'

#
# Delete article
#
exports.destroy = (req, res) ->
  tracker = req.tracker
  tracker.remove (err) ->
    req.flash 'notice', tracker.name + ' was successfully deleted.'
    res.redirect '/trackers'

#
# Articles index
#
exports.index = (req, res) ->
  Tracker.list req.user, (err, trackers) ->
    res.render 'trackers/index',
      trackers: trackers
#
# Articles index
#
exports.index_json = (req, res) ->
  Tracker.list req.user, (err, trackers) ->
    res.json 
      type: 'trackers:list'
      data: trackers

#
# Find tracker by ID
#
exports.load = (req, res, next, id) ->
  Tracker.findById(id).exec (err, tracker) ->
    return next err if err
    return next new Error 'Failed to load tracker' if not tracker
      
    req.tracker = tracker
    next()
