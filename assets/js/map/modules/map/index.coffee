$.ajax('/js/map/modules/map/template.html')
.done (data)->
  $('#map-container').append(data)
  $script.done 'MapModule'

angular.module("MapModule", []).value("version", "0.1").service "leaflet", ($rootScope) ->

  cloudmadeUrl = 'http://{s}.tile.cloudmade.com/341921c07bed461d8a66531ee02d112f/{styleId}/256/{z}/{x}/{y}.png'
  cloudmadeAttribution = 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade'
  mapboxUrl = 'https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/{z}/{x}/{y}.png'
  mapboxAttribution = 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade'

  normal   = L.tileLayer      cloudmadeUrl, styleId: 997,   attribution: cloudmadeAttribution
  minimal   = L.tileLayer     cloudmadeUrl, styleId: 22677, attribution: cloudmadeAttribution
  midnight  = L.tileLayer     cloudmadeUrl, styleId: 999,   attribution: cloudmadeAttribution
  forsquare  = L.tileLayer    mapboxUrl,                    attribution: mapboxAttribution
  motorways = L.tileLayer     cloudmadeUrl, styleId: 46561, attribution: cloudmadeAttribution
  @trackers = L.layerGroup()
  @tracks = L.layerGroup()

  @map = L.map 'map',
    center: new L.LatLng(50.61919,26.265257)
    zoom: 17
    layers: [normal, motorways, @trackers]

  @baseMaps = 
    "Normal": normal
    "Minimal": minimal
    "Night View": midnight

  @overlayMaps = 
    "Motorways": motorways
    "Trackers": @trackers
    "Tracks": @tracks

  L.control.layers(@baseMaps, @overlayMaps).addTo(@map)

  @