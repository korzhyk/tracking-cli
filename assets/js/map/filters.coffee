myFilters = angular.module 'myFilters', []

myFilters.filter 'timeAgo', ->
  (date)->
    m = moment(date)
    m.fromNow() if m

myFilters.filter 'speed', ->
  (speed)->
    "#{parseInt(speed, 10)} км/год"

myFilters.filter 'direction', ->
  (deg) ->
    deg = parseFloat deg if typeof deg is 'String'
    dir = ''
      
    offset = 22.5
    d = (deg - offset) / (offset * 2)
    
    dir += if d <= 0 or d >= 7
      'Північ'
    else if d <= 1
      'Північний схід'
    else if d <= 2
      'Схід'
    else if d <= 3
      'Південний схід'
    else if d <= 4
      'Південь'
    else if d <= 5
      'Південни захід'
    else if d <= 6
      'Захід'
    else 'Північний захід'

myFilters.filter 'moment', ->
  (m, format)->
    m = moment(m)
    return unless m or m.isValid()

    m.format(format or 'dddd, MMMM DD YYYY, h:mm:ss')