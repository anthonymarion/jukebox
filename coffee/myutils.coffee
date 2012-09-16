String.prototype.format = ->
  this.replace /{(\d+)}/g, (match, number) ->
    if typeof args[number] isnt 'undefined' then args[number] else "{#{number}}"

($) ->
  $.QueryString = (a) ->
    return {} if a is ''

    b = {}
    for i in [0..a.length]
      p = a[i].split '='
      continue if p.length isnt 2
      b[p[0]] = decodeURIComponent p[1].replace /\+/g, ' '
    return b
  .call window, window.location.search.substr(1).split('&')
.call window, jQuery
