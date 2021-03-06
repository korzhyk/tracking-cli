// Generated by CoffeeScript 1.6.2
(function() {
  L.Polyline = L.Polyline.extend({
    distance: function() {
      var curr, i, next, point, total, _ref;

      total = 0;
      _ref = this._latlngs;
      for (i in _ref) {
        point = _ref[i];
        curr = point;
        next = this._latlngs[i + 1];
        if (next) {
          total += curr.distanceTo(next);
        }
      }
      return total;
    }
  });

}).call(this);
