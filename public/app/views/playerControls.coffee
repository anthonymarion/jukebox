template = Handlebars.compile require('templates')['playerControls.mjs']
Jukebox = require '../libs/jukebox'

class PlayerControlsView extends Backbone.View
  videoProgressTime: 0
  totalPlayTime: 1

  events:
    "click #play":     "evPlay"
    "click #pause":    "evPause"
    "click #back":     "evBack"
    "click #next":     "evNext"
    "click #shuffle":  "evShuffle"
    "click #loop":     "evLoop"

  initialize: ->
    @render()
    window.jukebox.onVideoChanged.addHandler @onVideoChanged
    window.jukebox.onVideoProgressTimeChanged.addHandler @onVideoProgressTimeChanged
    window.jukebox.onVideoLoadedProgressChanged.addHandler @onVideoLoadedProgressChanged
    window.jukebox.onLoadingNewPlaylist.addHandler @onLoadingNewPlaylist

  onLoadingNewPlaylist: (@playlist) =>
    console.log "Loading #{@playlist}"
    console.log @$('#now-playing-info')
    @$('#now-playing-info').text "Loading playlist #{@playlist}..."

  onVideoChanged: (@videoInfo) =>
    @videoProgressTime = 0
    @totalPlayTime = @videoInfo.length
    @$('.progress .bar').css('width', (@videoProgressTime / @totalPlayTime) * 100 + '%')
    @render()

  onVideoProgressTimeChanged: (@videoProgressTime) =>
    @$('.progress .bar').css('width', (@videoProgressTime / @totalPlayTime) * 100 + '%')

  onVideoLoadedProgressChanged: =>
    # TODO
    #@render()

  evPlay: (event) ->
    window.jukebox.play()

  evPause: (event) ->
    window.jukebox.pause()

  evBack: (event) ->
    window.jukebox.playPrev()

  evNext: (event) ->
    window.jukebox.playNext()

  evShuffle: (event) ->
    window.jukebox.toggleShuffle()

  evLoop: (event) ->
    window.jukebox.toggleLoop()

  render: ->
    @$el.html template {
      details: window.jukebox.nowPlayingInfo() or 'Select a channel to begin!'
      progressPercent: (@videoProgressTime / @totalPlayTime) * 100
    }

module.exports = PlayerControlsView
