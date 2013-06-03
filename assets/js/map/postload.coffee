angular.bootstrap document, [
  'mapApp'
  'TrackersModule'
  'MapModule'
  'socket.io'
]


lc =  $('#loading-container')
mc =  $('#main-container')

setTimeout ->
  lc.transition opacity: 0, -> this.remove()
  mc.transition opacity: 1, scale: 1
, 1000
