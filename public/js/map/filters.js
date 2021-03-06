// Generated by CoffeeScript 1.6.2
(function() {
  var myFilters;

  myFilters = angular.module('myFilters', []);

  myFilters.filter('timeAgo', function() {
    return function(date) {
      var m;

      m = moment(date);
      if (m) {
        return m.fromNow();
      }
    };
  });

  myFilters.filter('speed', function() {
    return function(speed) {
      return "" + (parseInt(speed, 10)) + " км/год";
    };
  });

  myFilters.filter('direction', function() {
    return function(deg) {
      var d, dir, offset;

      if (typeof deg === 'String') {
        deg = parseFloat(deg);
      }
      dir = '';
      offset = 22.5;
      d = (deg - offset) / (offset * 2);
      return dir += d <= 0 || d >= 7 ? 'N' : d <= 1 ? 'NE' : d <= 2 ? 'E' : d <= 3 ? 'SE' : d <= 4 ? 'S' : d <= 5 ? 'SW' : d <= 6 ? 'W' : 'NW';
    };
  });

  myFilters.filter('moment', function() {
    return function(m, format) {
      m = moment(m);
      if (!(m || m.isValid())) {
        return;
      }
      return m.format(format || 'dddd, MMMM DD YYYY, h:mm:ss');
    };
  });

}).call(this);
