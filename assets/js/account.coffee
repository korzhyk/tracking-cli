$script.ready [ 'jquery', 'moment' ], ->
  # Auto update
  setInterval ->
    $('[data-timeago]').each (i, el)->
      $el = $(el)
      m = moment($el.data('timeago'))
      return unless m
      # Change text
      $el.text(
        if text = $el.text().replace('{{timeago}}', m.fromNow()) or text else m.fromNow()
      )
      # Set title
      $el.attr 'title'
      , if title = $el.attr('title') then title.replace('{{timeago}}', m.format('LLLL')) or title else m.format('LLLL')
  , 1000