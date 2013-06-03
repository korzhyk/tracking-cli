mongoose = require 'mongoose'
mongoose_times = require 'mongoose-times'
mongoose_cache = require 'mongoose-redis-cache'
bcrypt = require 'bcrypt'

#
# User Schema
#
Schema = mongoose.Schema

UserSchema = new Schema
  name:
    first:
      type: String
      trim: true
    last:
      type: String
      trim: true
  email:
    type: String
    trim: true
    unique: true
    required: true
  username:
    type: String
    trim: true
    required: true
    unique: true
  password:
    type: String
    required: true
  access_token:
    type: String
    unique: true
    
UserSchema.set 'redisCache', yes
UserSchema.plugin mongoose_times, created: "created_at", lastUpdated: "updated_at"

UserSchema.virtual('password_confirmation', required: true)
  .get -> @password
  
UserSchema.virtual('fullname', required: true)
  .get -> 
    fullname = []
    fullname.push @name.first if @name.first
    fullname.push @name.last if @name.last
    fullname.join ' '
  .set (value)-> [@name.first, @name.last] = value.split ' '

UserSchema.path('username').validate (val)->
  val?
, 'Email not valid'

UserSchema.path('email').validate (val)->
  /@/.test val
, 'Email not valid'

UserSchema.path('username').validate (val)->
  /\w/.test val
, 'Email not valid'

#
# Hash password before saving
#
UserSchema.pre 'save', (next) ->
  @email = @email.lower
  SALT_WORK_FACTOR = 10

  if !@isModified 'password'
    console.log 'Password not modified'
    return next()

  return next() unless @isModified 'password'

  bcrypt.genSalt SALT_WORK_FACTOR, (err, salt)=>
    return next err if err
    bcrypt.hash @password, salt, (err, hash)=>
      return next err if err
      @password = hash
      next()

#
# Compare password method for authentication
#
UserSchema.methods.comparePassword = (candidatePassword, cb) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    return cb err if err
    cb(null, isMatch)

UserSchema.methods.generateRandomToken = (cb)->
  SALT_WORK_FACTOR = 10
  bcrypt.genSalt SALT_WORK_FACTOR, cb

UserSchema.statics =
  list: (cb) ->
    @find().sort
      username: 1
    .exec(cb)

User = mongoose.model 'User', UserSchema