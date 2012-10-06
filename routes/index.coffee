
#
# * GET home page.
# 
exports.index = (req, res) ->
  res.render "index",
    scripts: [
      'jquery'
      'underscore'
      'swfobject'
      'jukebox'
      'jukebox-app'
    ]
    title: "Jukebox"

