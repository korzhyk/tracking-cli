_ = require 'lodash'
crypto = require 'crypto'
moment = require 'moment'

prepareForMethod = (methods)->
  type = typeof methods

  if type isnt 'object'
    methods = switch type
                when 'function' then get: methods
                when 'array'
                  obj = {}
                  obj.get = methods[0]
                  obj.set = methods[1] if methods[1]?
                else throw new Error('Undefined methods for getter or setter!')
  methods
#
# Define getter and setter in class
#
# Exmpl:
#   class Foo
#     constructor: (name)->
#       @_name = name
#
#     @define 'to_s',
#       get: -> @_name
#
Function::define = (prop, methods)->
  Object.defineProperty @::, prop, prepareForMethod(methods)

#
# Define getter and setter for class
#
# Exmpl:
#   define Number, 'to_s',
#       get: -> @toString()
#
define = (obj, props)->
  for prop, methods of props
    Object.defineProperty obj::, prop, prepareForMethod(methods)

#
# String
#
String::_html_safe = yes
define String,
      'capitalize': -> @charAt(0).toUpperCase() + @slice(1).toLowerCase()
      'lower': -> @.toLowerCase()
      'upper': -> @.toUpperCase()
      'html_safe':
        get: -> @_html_safe or no
        set: (val)-> @_html_safe = !!val; @
      'md5': -> crypto.createHash('md5').update("#{@}").digest('hex')
      'to_json': -> JSON.parse("#{@}")

#
# Object
#
define Object,
      'to_s': -> @toString()

#
# Number
#
define Number,
      'to_s': -> @toString()
#
# Date
#
define Date,
      'to_s': -> moment(@).format()

#
# Array
#
define Array,
      'first':
        get: -> @[0]
        set: (value)-> @[0] = value

      'last':
        get: -> @[@length - 1]
        set: (value)-> @[@length - 1] = value

      'empty': -> @length > 0

