myDirectives = angular.module 'myDirectives', []

myDirectives.directive 'pickdateJs', ->
  restrict: 'A'
  require: '?ngModel'
  link: (scope, element, attrs, ngModel)->
    element.pickadate()
    picker = element.pickadate('picker')

    if attrs.min
      scope.$watch attrs.min, (value)->
        picker.set 'min', if value.toDate then value.toDate() else value

    if attrs.max
      scope.$watch attrs.max, (value)->
        picker.set 'max', if value.toDate then value.toDate() else value

    picker.on 'close', ->
      scope.$apply ->
        date = picker.get 'select'
        m = moment(date.obj)
        ngModel.$modelValue = m
        ngModel.$setViewValue(m.format())

        ngModel.$render()

    ngModel.$formatters.unshift (modelValue)->
      return "" unless modelValue
      moment(modelValue).format()

    ngModel.$parsers.unshift (viewValue)->
      return "" unless viewValue
      moment(viewValue)

chart = ['$filter']
chart.push ($filter)->
  restrict: 'E'
  template: '<div class="chart"></div>'
  transclude: true
  replace: true

  link: (scope, element, attrs)->
    chartsDefaults =
      chart:
        renderTo: element[0]
        type: attrs.type or null
        animation: Highcharts.svg
        height: attrs.height or 200
        width: attrs.width or 278
        marginRight: 10
      credits:
        enabled: no
      title: no
      tooltip:
        formatter: ->
          m = moment(@x)
          $filter('speed') [@y]
      xAxis:
        type: "datetime"
        tickPixelInterval: 100
      yAxis:
        title: no
        min: 0
      legend:
        enabled: no
      series: [name: 'Speed', data:[]]

    chart = new Highcharts.Chart(chartsDefaults)

    scope.$watch attrs.trigger, (trigger)->
      data = scope.$eval(attrs.serie) or []
      data.pop()
      s = chart.series[0]
      s.setData(data)

    scope.$watch attrs.last, (last)->
      return unless last
      s = chart.series[0]
      s.setData([]) if last.first - s.data.last?.x > 50000
      s.addPoint(last, true, s.data.length > 10)
    , true

myDirectives.directive 'chart', chart

myDirectives.directive 'currentTime', ->
  (scope, element, attrs)->
    updateTime = ->
      m = moment()
      element.html m.format(attrs.format or 'dddd, MMMM DD YYYY, h:mm:ss')

    setInterval updateTime, 1000

myDirectives.directive 'trackersCount', ->
  (scope, element, attrs)->
    scope.$watch 'trackers', (trackers)->
      all = trackers?.length
      active = _.filter(trackers, (t)-> t.active).length
      element.html all
      element.parent().tooltip('destroy')
      element.parent().tooltip(html: yes, title: "Active: #{active}\nNot active: #{all-active}")

geocode = ['$http']
geocode.push ($http)->
  (scope, element, attrs)->
    url = 'http://geocode-maps.yandex.ru/1.x/?kind=' + (attrs.kind or 'house') + '&results=1&format=json&geocode='

    lang = switch navigator.language
      when 'uk', 'uk-ua' then 'uk-UA'
      when 'ru' then 'ru-RU'
      when 'en' then 'en-US'
      else 'en-US'

    scope.$watch attrs.geocode, (c)->
      return unless c
      promise = $http.get "#{url}#{c.lng},#{c.lat}&lang=#{lang}"
      promise.then (res)->
        street = res.data.response.GeoObjectCollection.featureMember[0].GeoObject.name
        description = res.data.response.GeoObjectCollection.featureMember[0].GeoObject.description
        element.html street
        element.tooltip('destroy')
        element.tooltip(html: yes, title: description)
        

myDirectives.directive 'geocode', geocode

myDirectives.directive 'tooltip', ->
  (scope, element, attrs)->
    attrs.$observe 'tooltip', (title)->
      element.tooltip('destroy')
      element.tooltip(title: title)

myDirectives.directive 'direction', ->
  (scope, element, attrs)->
    scope.$watch attrs.direction, (direction)->
      return unless direction
      element.css rotate: direction

myDirectives.directive 'status', ->
  (scope, element, attrs)->
    scope.$watch attrs.status, (status)->
      return unless status
      element.attr 'class', 'status ' + status
