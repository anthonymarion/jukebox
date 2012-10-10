layout = Handlebars.compile require('templates')['app.mjs']
Jukebox = window.Jukebox = require './libs/jukebox'

NavigationView = require './views/navigation'
PlayerControlsView = require './views/playerControls'

class JukeboxApp extends Backbone.View
  playerId: "jukebox-yt-player"

  initialize: ->
    window.jukebox = @jukebox = new Jukebox @playerId
    @render()
    @initializeYoutubePlayer()
    @navigationView = new NavigationView(el: @$('#nav'), jukebox: @jukebox)
    @playerControlsView = new PlayerControlsView(el: @$('#controls'), jukebox: @jukebox)

  render: ->
    @$el.html layout()

  initializeYoutubePlayer: ->
    width = 400
    height = 300
    defaultVideoId = "5ShagXWQ6jI"

    onPlayerReady = (event) ->
      console.log 'Player ready'
      @jukebox.setPlayer event.target
      @jukebox.changeChannel 'liquicity'
      @jukebox.player.addEventListener 'onStateChange', 'window.Jukebox.onYoutubePlayerStateChange.fire'

    onStateChange = (event) =>
      @jukebox.onPlayerStateChanged.fire event.data

    window.onYouTubeIframeAPIReady = =>
      console.log 'Youtube ready'
      player = new YT.Player(@playerId, {
        height: height
        width: width
        videoId: defaultVideoId
        events:
          onReady: onPlayerReady
          onStateChange: onStateChange
      })

module.exports = JukeboxApp
