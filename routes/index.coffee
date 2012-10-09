exports.index = (req, res) ->
  res.render "index",
    scripts: [
      'jquery'
      'underscore'
      'bootstrap'
      'swfobject'
      'backbone'

      'jukebox'
      'jukebox-app'
    ]
    title: "Jukebox"

