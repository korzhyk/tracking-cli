mongoose = require 'mongoose'

#
# Getters and setters for tags
#
getTags = (tags) ->
  tags.join ','

setTags = (tags) ->
  tags.split ','

#
# Article Schema
#
Schema = mongoose.Schema

ArticleSchema = new Schema
  title:
    type: String
    trim: true
    required: true

  body:
    type: String
    required: true
    
  tags:
    type: []
    get: getTags
    set: setTags
    
  createdAt:
    type: Date
    default: Date.now
    
#
# Schema statics
#
ArticleSchema.statics =
  list: (cb) ->
    this.find().sort
      createdAt: -1
    .exec(cb)

Article = mongoose.model 'Article', ArticleSchema