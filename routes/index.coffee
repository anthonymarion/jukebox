exports.index = (req, res) ->
  res.render "index",
    scripts: [
      'jquery'
      'bootstrap'
      'underscore'
      'swfobject'
      'jukebox'
      'jukebox-app'
    ]
    title: "Jukebox"

