$script [ '/js/extends.js' ], 'extends'
$script [ '/vendor/jquery/jquery.js' ], 'jquery'
$script [ '/vendor/moment/moment.js' ], 'moment'
#  $script [ '/vendor/moment/uk.js' ], 'moment'

jQueryReady =  ->
  $script [ '/vendor/jquery_ujs.js' ], 'jquery_ujs'
  $script [ '/vendor/bootstrap/bootstrap/js/bootstrap.js' ], 'bootstrap'

$script.ready 'jquery', jQueryReady
