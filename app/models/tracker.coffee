mongoose = require 'mongoose'
mongoose_times = require 'mongoose-times'
mongoose_cache = require 'mongoose-redis-cache'

#
# Tracker Schema
#
Schema = mongoose.Schema

TrackerSchema = new Schema
  user:
    type: Schema.ObjectId
    ref: 'UserSchema'
    required: true
  uid:
    type: String
    require: true
    unique: true
  name:
    type: String

#
# Schema statics
#
TrackerSchema.statics =
  list: (cb)->
    @find().sort
      created_at: -1
    .lean()
    .exec(cb)
    
TrackerSchema.set 'redisCache', yes
TrackerSchema.plugin mongoose_times, created: "created_at", lastUpdated: "updated_at"

Tracker = mongoose.model 'Tracker', TrackerSchema

exports = TrackerSchema