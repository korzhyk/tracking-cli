_ = require 'lodash'
#
# Exports
#
module.exports = (name)->
  (req, res, next)->
    res.locals.app_name = name or 'App'
    res.locals.title = name or 'App'
    res.locals.current_user = req.user or false
    res.locals.req = req
    res.locals.flash = req.flash.bind(req)
    res.locals.tag = tag
    res.locals.tag_self = tag_self

    res.locals.tag_open = tag_open
    res.locals.tag_close = tag_close

    res.locals.css = css
    res.locals.js = js

    res.locals.link_to = link_to.bind(req)
    res.locals.input = input

    res.locals.form = Form
    res.locals.Form = Form

    res.locals.icon = icon
    res.locals.csrf_meta = csrf_meta.bind(req)
    res.locals.csrf = csrf.bind(req)

    next()


#
# CSRF Meta tags
#
csrf_meta = ->
  csrf = ''
  csrf += tag_self 'meta', name: 'csrf-param', content: '_csrf'
  csrf += tag_self 'meta', name: 'csrf-token', content: @session._csrf
  csrf

csrf = ->
  tag_self 'input', name: '_csrf', value: @session._csrf, type: 'hidden'

#
# Convert options object to attributes
#
options_to_attributes = (opts, prefix)->
  return "" unless opts?
  attributes = ""
  for attr, value of opts
    if typeof value is 'object'
      attributes += options_to_attributes(value, attr)
    else if typeof value is 'boolean'
      attr = "#{prefix}-#{attr}" if prefix
      attr = attr.lower
      if value
        attributes += " #{attr}"
      else
        attributes += " #{attr}='#{value}"
    else
      attr = "#{prefix}-#{attr}" if prefix
      attr = attr.lower
      value = _.escape(value).replace /'/g, "\'"
      attributes += " #{attr}='#{value}'"
  attributes

#
# Open tag
#
tag_open = (name, options, self_close)->
  close = if self_close then '/' else ''
  "<#{name}#{options_to_attributes(options)}#{close}>"

#
# Close tag
#
tag_close = (name)->
  "</#{name}>"

#
# Normal tag
#
tag = (name, text, opts)->
  name ?= 'div'
  if typeof text is 'object'
    opts = text
    text = ''
  text = _.escape(text) unless text.html_safe
  "#{tag_open(name, opts)}#{text}#{tag_close(name)}"

#
# Tag self closing
#
tag_self = (name, opts)->
  "#{tag_open(name, opts, yes)}"

#
# Input field
#
input = (name, opts)->
  opts ?= {}
  opts.type ?= 'text'
  opts.name = name
  tag_self 'input', opts

#
# Link to
#
link_to = (text, url, opts)->
  opts ?= {}
  opts.href = url
  tag 'a', text, opts

#
# CSS stylesheet
#
css = ->
  args = arguments
  links = ""
  for style in args
    links += tag_self 'link',
      href: "/#{style}.css"
      rel: 'stylesheet'
  links

#
# JS Scripts
#
js = ->
  args = arguments
  scripts = ""
  for script in args
    if typeof script is 'object'
      script.src = "/#{script.src}.js"
      scripts += tag 'script', script
    else
      scripts += tag 'script', src: "/#{script}.js"
  scripts

icon = (name)->
  name ?= 'ok'
  tag 'span', class: "glyphicon glyphicon-#{name}"

class Form
  constructor: (@resource, opts)->
    opts ?= {}
    @resourceName = @resource?.constructor?.modelName or opts?.resourceName or no
    @errors = @resource?.errors or {}
    return @

  generateName: (name)->
    if @resourceName
      "#{@resourceName}[#{name}]"
    else
      name

  generateId: (name)->
    if @resourceName
      "#{@resourceName}_#{name}".lower
    else
      name

  begin: (opts)->
    opts ?= {}
    opts.method ?= 'POST'
    opts.id ?= @generateId('new')
    tag_open 'form', opts

  end: ->
    tag_close 'form'

  input: (name, opts)->
    opts ?= {}
    opts.name = @generateName(name)
    opts.id = @generateId(name)
    opts.value ?= @resource[name] if @resource?[name]
    opts.type ?= @type(name)

    tag_self 'input', opts

  required: (name)->
    model_field = @resource.schema.tree[name]
    model_field.required? or model_field.options?.required?

  type: (name)->
    model_field = @resource?.schema.tree[name]

    type = if /email/.test name then 'email'
    else if /password/.test name then 'password'
    else switch typeof model_field
      when 'function'
        model_field.name
      when 'object'
        model_field.type?.name or model_field.options?.type?.name
      else
        'text'

    type = switch type
      when 'String' then 'text'
      when 'Date' then 'date'
      when 'Number' then 'number'
      else type

    type or 'text'

  button: (text, opts)->
    opts ?= {}
    opts.type ?= 'submit'
    opts.class ?= 'btn btn-primary'
    tag 'button', text, opts