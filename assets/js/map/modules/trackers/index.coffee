$.ajax('/js/map/modules/trackers/template.html')
.done (data)->
  $('#sidebar-content').append(data)
  $script.done 'TrackersModule'

class EventsList
  constructor: ->

class Point
  constructor: (obj)->
    @_latLng = L.GeoJSON.coordsToLatLng(obj.geometry.coordinates)
    @[key] = prop for key, prop of obj.properties
    @date = moment.utc(@date)
    return @

  toSpeedChart: ->
    [@date.valueOf(), parseInt(@speed, 10)]

  @define 'latlng', -> @_latLng

class PointsList

  LIMIT_POINT_LIST = 10000

  constructor: (@tracker)->
    @list = []
    return @

  add: ->
    for point in arguments
      last = @last
      @list.push if point instanceof Point then point else point = new Point(point)
      @list.sort (i, n)-> i.date.valueOf() - n.date.valueOf()
      bean.fire @, 'new:point', @last

  clear: -> @list = []

  limit: (max=10)-> @list.slice(-max)

  latLngs: ->
    @list.map (p)-> p.latlng

  toSpeedChart: (limit=10)->
    result = []
    for p in @limit(limit)
      if p.status is 'AUTOSTART' or last?.status is 'AUTOSTOP'
        result = []
        continue
      continue if p.status not in ['AUTO']
      last = p
      result.push [p.date.valueOf(), parseInt(p.speed, 10)]
    result

  eachPoint: (fn)->
    @list.forEach fn

  @define 'last', -> _.last(@list)

class Tracker
  constructor: (obj)->
    { _id, @name } = obj
    @id            = _id
    @points        = new PointsList(@)
    @pointsHistory = new PointsList(@)
    @events        = new EventsList(@)
    @marker        = L.marker()
    @historyLayer  = L.featureGroup([])

    bean.on @points, 'new:point', (point)=> 
      markerEmpty = !@marker._latLng
      @marker.setLatLng(point.latlng)
      bean.fire @, 'marker:set:latlng', @marker if markerEmpty

    bean.on @, 'last:points', => @points.add.apply(@points, arguments)
    bean.on @, 'points', =>
      bean.fire @, 'history:start', @
      @historyLayer.clearLayers()
      @pointsHistory.clear()
      @pointsHistory.add.apply(@pointsHistory, arguments)
      @buildHistoryLayers()
    return @

  buildHistoryLayers: ->
    pline = L.polyline([])
    @pointsHistory.eachPoint (p)->
      pline.addLatLng(p)
    @historyLayer.addLayer(pline)
    console.log pline
    bean.fire @, 'history:done', @


  showHistoryFor: (opts)->

  @define 'active', -> !!@livePoint

  @define 'livePoint', -> @points.last

TrackersList = ['$http', '$rootScope', 'socket', 'leaflet']
TrackersList.push ($http, $rootScope, socket, leaflet)->
  @trackersUrl = '/trackers.json'
  @trackersList = []
  @get = (id)-> _.find @trackersList, id: id

  @trackerLayer = leaflet.trackers
  @tracksLayer = leaflet.tracks

  socket.on 'live:point', (res)=>
    tracker = @get(res.tracker_id)
    bean.fire tracker, 'last:points', res.data

  socket.on 'last:points', (res)=>
    tracker = @get(res.tracker_id)
    bean.fire tracker, 'last:points', res.data

  socket.on 'points', (res)=>
    tracker = @get(res.tracker_id)
    bean.fire tracker, 'points', res.data


  @fetchTrackers = (opts, done)->
    if typeof opts is 'function'
      done = opts
      opts = {}

    $http.get(@trackersUrl)
    .then (res)=>
      type = res.data.type
      trackers = res.data.data
      for t in trackers
        t = new Tracker(t)
        bean.on t, 'marker:set:latlng', (m)->
          m.addTo(leaflet.trackers)
        t.historyLayer.addTo(leaflet.tracks)
        bean.on t, 'history:done', ->
          try
            leaflet.map.fitBounds t.historyLayer.getBounds()
          catch e
            console.log e
        socket.emit 'get:last:points', tracker_id: t.id, limit: 10
        @trackersList.push(t) 
      done(@trackersList)
      $rootScope.trackers = @trackersList

  @updateTrackers = ->
    $http.get(@trackersUrl).then (res)=>
      done(@trackersList)

  @showHistoryFor = (t, opts)->
    opts ?= {}
    opts.tracker_id = t.id
    socket.emit 'get:points', opts

  @active = ->
    _.select @trackersList, (t)->  moment().valueOf() - t.livePoint?.date.valueOf() > 60000 or t.active


TrackersCtrl = ['$scope', 'TrackersList', 'socket', 'leaflet']
TrackersCtrl.push ($scope, TrackersList, socket, leaflet)->
  $scope.liveMode = yes

  $scope.trackers = []
  $scope.trackersList = TrackersList

  $scope.dateRange =
    from: moment().startOf('day')
    to: moment().endOf('day')

  setTrackers = (trackers)-> $scope.trackers = trackers;

  TrackersList.fetchTrackers $scope.dateRange, setTrackers

  $scope.trackerChanged = ->
    $scope.selectedTracker?.name

  $scope.openStatsBar = ->

  $scope.panToSelectedTracker = (t)->
    tracker = t or $scope.selectedTracker
    panTo = tracker.livePoint?.latlng
    leaflet.map.panTo(panTo) if panTo

  $scope.fetchHistory = ->
    TrackersList.showHistoryFor($scope.selectedTracker, $scope.dateRange)

  $scope.selectTracker = (t)-> $scope.selectedTracker = t

  $scope.panToTracker = $scope.panToSelectedTracker

  $scope.highlightLayer = (l)->
    l.setStyle
      color: '#f00'
      opacity: 1
    l.bringToFront()

  $scope.resetHighlight = (l)->
    l.setStyle L.Path::options

  $scope.fitLayer = (l)->
    leaflet.map.fitBounds l.getBounds()
    
  $scope.$watch 'liveMode', (ugu)->
    if ugu
      leaflet.map.addLayer leaflet.trackers
      leaflet.map.removeLayer leaflet.tracks
    else
      $scope.tracksSlectedTracker = false
      leaflet.map.removeLayer leaflet.trackers
      leaflet.map.addLayer leaflet.tracks

  $scope.$watch 'selectedTracker.livePoint', (p)->
    return unless p
    if $scope.tracksSlectedTracker
      leaflet.map.panTo p.latlng
  , true

angular.module('TrackersModule', [])
  .controller('TrackersCtrl', TrackersCtrl)
  .service('TrackersList', TrackersList)
