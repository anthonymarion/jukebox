exports.index = (req, res) ->
  res.render "index",
    scripts: [
      'jquery'
      'underscore'
      'bootstrap'
      'backbone'
      'handlebars'
    ]
    title: "Jukebox"

