$script [ '/js/extends.js' ], 'extends'
$script [ '/vendor/bean.js' ], 'bean'
$script [ '/vendor/lodash.js' ], 'lodash'
$script [ '/vendor/moment/moment.js' ], ->
$script [ '/vendor/moment/uk.js' ], 'moment'
$script [ '/vendor/jquery/jquery.js' ], 'jquery'
$script [ '/vendor/spin.js' ], 'spin.js'
$script [ '/socket.io/socket.io.js' ], 'socket.io'

$script.ready [ 'jquery', 'spin.js' ], ->
  $script [ '/js/spin.js' ], 'spin'
  $script [ '/vendor/jquery.i18n.js' ], 'i18n'

$script.ready [ 'extends', 'jquery', 'bean', 'spin', 'i18n' ], -> $script [ '/js/map/preload.js' ], 'preload'

$script [ '/vendor/highcharts/highcharts.src.js' ], 'highcharts', ->
  Highcharts.setOptions global:
    useUTC: false

$script.ready 'extends', ->
    $css '/vendor/Leaflet/leaflet.css'
    $css '/vendor/Leaflet.draw/leaflet.draw.css'
    $css '/vendor/Leaflet.label/leaflet.label.css'
    $css '/vendor/Leaflet.markercluster/MarkerCluster.css'
    $css '/css/map/leaflet.css'
    $css '/vendor/baron/baron.css'

jQueryReady =  ->
  $script [ '/vendor/jquery_ujs.js' ], 'jquery_ujs'
  $script [ '/js/center_box.js' ], 'center-box'
  $script [ '/vendor/pickadatejs/picker.js' ], ->
    $css '/vendor/pickadatejs/themes/classic.css'
    $css '/vendor/pickadatejs/themes/classic.date.css'
    $css '/vendor/pickadatejs/themes/classic.time.css'
    $script [
      '/vendor/pickadatejs/picker.date.js'
      '/vendor/pickadatejs/picker.time.js'
    ],'pickadate'
  $script [ '/vendor/jquery.transit.js' ], 'transit'
  $script [ '/vendor/bootstrap/bootstrap/js/bootstrap.js' ], 'bootstrap'

$script.ready 'jquery', jQueryReady

$script.ready [ 'preload' ], ->

  $script [ '/vendor/Leaflet/leaflet-src.js' ], ->
    $script [
      '/js/map/leaflet.js'
      '/vendor/Leaflet.draw/leaflet.draw.js'
      '/vendor/Leaflet.label/leaflet.label.js'
      '/vendor/Leaflet.markercluster/leaflet.markercluster.js'
    ], 'leaflet'

  $script [ '/vendor/angular/angular.js' ], ->
    $script [
      '/vendor/angular.i18n/localization.js'
      '/vendor/angular.ui/ui-bootstrap-tpls-0.2.0.js'
    ], 'angular'


  AngularReady =  ->
    $script [
      '/js/map/app.js'
      '/js/map/services.js'
      '/js/map/directives.js'
      '/js/map/filters.js'
      '/js/map/modules/trackers/index.js'
      '/js/map/modules/map/index.js'
    ], 'mapApp'
    
  $script.ready [ 'leaflet', 'angular' ], AngularReady

  bean.on document, 'app-ready', ->
    $script [ '/js/map/postload.js' ]

  $script.ready [ 'socket.io', 'mapApp', 'TrackersModule', 'MapModule' ], ->
    bean.fire document, 'app-ready'
