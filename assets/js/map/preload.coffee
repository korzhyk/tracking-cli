domReady = ->
  lc =  $('#loading-container')
  mc =  $('#main-container')
  lc.spin('large', '#aaa')

$(document).ready domReady

# l = $.getJSON '/locales/' + navigator.language + ".json"
l = $.getJSON '/locales/en.json'
l.success (data)->
  $.i18n.setDictionary data


  window.__ = -> $.i18n._.apply($.i18n, arguments)