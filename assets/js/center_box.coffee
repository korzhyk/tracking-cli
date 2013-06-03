(($, window)->
  
  $.fn.centerBox = ->
    update = =>
      if $(window).width() > 480
        @css "margin-top": Math.max(40, ($(window).height() - @outerHeight()) / 2 - 40)
      else
        @css "margin-top", 40

    $(window).resize -> update()
    update()
    @
  
)(jQuery, window)