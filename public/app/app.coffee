layout = Handlebars.compile require('templates')['app.mjs']
Jukebox = window.Jukebox = require './libs/jukebox'

NavigationView = require './views/navigation'

class JukeboxApp extends Backbone.View
  playerId: "jukebox-yt-player"

  initialize: ->
    window.jukebox = @jukebox = new Jukebox @playerId
    @render()
    @initializeYoutubePlayer()
    @navigationView = new NavigationView(el: @$('#nav'), jukebox: @jukebox)
  render: ->
    @$el.html layout()

  initializeYoutubePlayer: ->
    defaultVideoId = "5ShagXWQ6jI"
    swfobject.embedSWF "http://www.youtube.com/v/#{defaultVideoId}?enablejsapi=1&playerapiid=#{@playerId}&version=3", @playerId, 480, 360, "8", null, null, { allowScriptAccess: 'always' }, { id: @playerId }
    window.onYouTubePlayerReady = (playerId) =>
      return if playerId isnt @playerId
      @jukebox.changeChannel 'liquicity'
      @jukebox.setPlayer document.getElementById playerId
      player.addEventListener 'onStateChange', 'window.Jukebox.onYoutubePlayerStateChange.fire'

module.exports = JukeboxApp
