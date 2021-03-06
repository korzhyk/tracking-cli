// Generated by CoffeeScript 1.6.2
(function() {
  var EventsList, Point, PointsList, Tracker, TrackersCtrl, TrackersList;

  $.ajax('/js/map/modules/trackers/template.html').done(function(data) {
    $('#sidebar-content').append(data);
    return $script.done('TrackersModule');
  });

  EventsList = (function() {
    function EventsList() {}

    return EventsList;

  })();

  Point = (function() {
    function Point(obj) {
      var key, prop, _ref;

      this._latLng = L.GeoJSON.coordsToLatLng(obj.geometry.coordinates);
      _ref = obj.properties;
      for (key in _ref) {
        prop = _ref[key];
        this[key] = prop;
      }
      this.date = moment.utc(this.date);
      return this;
    }

    Point.prototype.toSpeedChart = function() {
      return [this.date.valueOf(), parseInt(this.speed, 10)];
    };

    Point.define('latlng', function() {
      return this._latLng;
    });

    return Point;

  })();

  PointsList = (function() {
    var LIMIT_POINT_LIST;

    LIMIT_POINT_LIST = 10000;

    function PointsList(tracker) {
      this.tracker = tracker;
      this.list = [];
      return this;
    }

    PointsList.prototype.add = function() {
      var last, point, _i, _len, _results;

      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        point = arguments[_i];
        last = this.last;
        this.list.push(point instanceof Point ? point : point = new Point(point));
        this.list.sort(function(i, n) {
          return i.date.valueOf() - n.date.valueOf();
        });
        _results.push(bean.fire(this, 'new:point', this.last));
      }
      return _results;
    };

    PointsList.prototype.clear = function() {
      return this.list = [];
    };

    PointsList.prototype.limit = function(max) {
      if (max == null) {
        max = 10;
      }
      return this.list.slice(-max);
    };

    PointsList.prototype.latLngs = function() {
      return this.list.map(function(p) {
        return p.latlng;
      });
    };

    PointsList.prototype.toSpeedChart = function(limit) {
      var last, p, result, _i, _len, _ref, _ref1;

      if (limit == null) {
        limit = 10;
      }
      result = [];
      _ref = this.limit(limit);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        if (p.status === 'AUTOSTART' || (typeof last !== "undefined" && last !== null ? last.status : void 0) === 'AUTOSTOP') {
          result = [];
          continue;
        }
        if ((_ref1 = p.status) !== 'AUTO') {
          continue;
        }
        last = p;
        result.push([p.date.valueOf(), parseInt(p.speed, 10)]);
      }
      return result;
    };

    PointsList.prototype.eachPoint = function(fn) {
      return this.list.forEach(fn);
    };

    PointsList.define('last', function() {
      return _.last(this.list);
    });

    return PointsList;

  })();

  Tracker = (function() {
    function Tracker(obj) {
      var _id,
        _this = this;

      _id = obj._id, this.name = obj.name;
      this.id = _id;
      this.points = new PointsList(this);
      this.pointsHistory = new PointsList(this);
      this.events = new EventsList(this);
      this.marker = L.marker();
      this.historyLayer = L.featureGroup([]);
      bean.on(this.points, 'new:point', function(point) {
        var markerEmpty;

        markerEmpty = !_this.marker._latLng;
        _this.marker.setLatLng(point.latlng);
        if (markerEmpty) {
          return bean.fire(_this, 'marker:set:latlng', _this.marker);
        }
      });
      bean.on(this, 'last:points', function() {
        return _this.points.add.apply(_this.points, arguments);
      });
      bean.on(this, 'points', function() {
        bean.fire(_this, 'history:start', _this);
        _this.historyLayer.clearLayers();
        _this.pointsHistory.clear();
        _this.pointsHistory.add.apply(_this.pointsHistory, arguments);
        return _this.buildHistoryLayers();
      });
      return this;
    }

    Tracker.prototype.buildHistoryLayers = function() {
      return bean.fire(this, 'history:done', this);
    };

    Tracker.prototype.showHistoryFor = function(opts) {};

    Tracker.define('active', function() {
      return !!this.livePoint;
    });

    Tracker.define('livePoint', function() {
      return this.points.last;
    });

    return Tracker;

  })();

  TrackersList = ['$http', '$rootScope', 'socket', 'leaflet'];

  TrackersList.push(function($http, $rootScope, socket, leaflet) {
    var _this = this;

    this.trackersUrl = '/trackers.json';
    this.trackersList = [];
    this.get = function(id) {
      return _.find(this.trackersList, {
        id: id
      });
    };
    this.trackerLayer = leaflet.trackers;
    this.tracksLayer = leaflet.tracks;
    socket.on('live:point', function(res) {
      var tracker;

      tracker = _this.get(res.tracker_id);
      return bean.fire(tracker, 'last:points', res.data);
    });
    socket.on('last:points', function(res) {
      var tracker;

      tracker = _this.get(res.tracker_id);
      return bean.fire(tracker, 'last:points', res.data);
    });
    socket.on('points', function(res) {
      var tracker;

      tracker = _this.get(res.tracker_id);
      return bean.fire(tracker, 'points', res.data);
    });
    this.fetchTrackers = function(opts, done) {
      var _this = this;

      if (typeof opts === 'function') {
        done = opts;
        opts = {};
      }
      return $http.get(this.trackersUrl).then(function(res) {
        var t, trackers, type, _i, _len;

        type = res.data.type;
        trackers = res.data.data;
        for (_i = 0, _len = trackers.length; _i < _len; _i++) {
          t = trackers[_i];
          t = new Tracker(t);
          bean.on(t, 'marker:set:latlng', function() {
            return t.marker.addTo(leaflet.trackers);
          });
          t.historyLayer.addTo(leaflet.tracks);
          bean.on(t, 'history:done', function() {
            var e;

            try {
              return leaflet.map.fitBounds(t.historyLayer.getBounds());
            } catch (_error) {
              e = _error;
              return console.log(e);
            }
          });
          socket.emit('get:last:points', {
            tracker_id: t.id
          });
          _this.trackersList.push(t);
        }
        done(_this.trackersList);
        return $rootScope.trackers = _this.trackersList;
      });
    };
    this.updateTrackers = function() {
      var _this = this;

      return $http.get(this.trackersUrl).then(function(res) {
        return done(_this.trackersList);
      });
    };
    this.showHistoryFor = function(t, opts) {
      if (opts == null) {
        opts = {};
      }
      opts.tracker_id = t.id;
      return socket.emit('get:points', opts);
    };
    return this.active = function() {
      return _.select(this.trackersList, function(t) {
        var _ref;

        return moment().valueOf() - ((_ref = t.livePoint) != null ? _ref.date.valueOf() : void 0) > 60000 || t.active;
      });
    };
  });

  TrackersCtrl = ['$scope', 'TrackersList', 'socket', 'leaflet'];

  TrackersCtrl.push(function($scope, TrackersList, socket, leaflet) {
    var setTrackers;

    $scope.liveMode = true;
    $scope.trackers = [];
    $scope.trackersList = TrackersList;
    $scope.dateRange = {
      from: moment().startOf('day'),
      to: moment().endOf('day')
    };
    setTrackers = function(trackers) {
      return $scope.trackers = trackers;
    };
    TrackersList.fetchTrackers($scope.dateRange, setTrackers);
    $scope.trackerChanged = function() {
      var _ref;

      return (_ref = $scope.selectedTracker) != null ? _ref.name : void 0;
    };
    $scope.openStatsBar = function() {};
    $scope.panToSelectedTracker = function(t) {
      var panTo, tracker, _ref;

      tracker = t || $scope.selectedTracker;
      panTo = (_ref = tracker.livePoint) != null ? _ref.latlng : void 0;
      if (panTo) {
        return leaflet.map.panTo(panTo);
      }
    };
    $scope.fetchHistory = function() {
      return TrackersList.showHistoryFor($scope.selectedTracker, $scope.dateRange);
    };
    $scope.selectTracker = function(t) {
      return $scope.selectedTracker = t;
    };
    $scope.panToTracker = $scope.panToSelectedTracker;
    $scope.highlightLayer = function(l) {
      l.setStyle({
        color: '#f00',
        opacity: 1
      });
      return l.bringToFront();
    };
    $scope.resetHighlight = function(l) {
      return l.setStyle(L.Path.prototype.options);
    };
    $scope.fitLayer = function(l) {
      return leaflet.map.fitBounds(l.getBounds());
    };
    $scope.$watch('liveMode', function(ugu) {
      if (ugu) {
        leaflet.map.addLayer(leaflet.trackers);
        return leaflet.map.removeLayer(leaflet.tracks);
      } else {
        $scope.tracksSlectedTracker = false;
        leaflet.map.removeLayer(leaflet.trackers);
        return leaflet.map.addLayer(leaflet.tracks);
      }
    });
    return $scope.$watch('selectedTracker.livePoint', function(p) {
      if (!p) {
        return;
      }
      if ($scope.tracksSlectedTracker) {
        return leaflet.map.panTo(p.latlng);
      }
    }, true);
  });

  angular.module('TrackersModule', []).controller('TrackersCtrl', TrackersCtrl).service('TrackersList', TrackersList);

}).call(this);
