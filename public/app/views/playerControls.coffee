template = Handlebars.compile require('templates')['playerControls.mjs']
Jukebox = require '../libs/jukebox'

class PlayerControlsView extends Backbone.View
  videoProgressTime: 0
  totalPlayTime: 1

  events:
    "click #playpause":     "evPlayPause"
    "click #back":          "evBack"
    "click #next":          "evNext"
    "click #shuffle":       "evShuffle"
    "click #loop":          "evLoop"
    "click #progress-bar":  "evProgressBarClicked"
    "change #volume":       "evVolumeChanged"

  initialize: ->
    @render()
    window.jukebox.onVideoChanged.addHandler @onVideoChanged
    window.jukebox.onVideoProgressTimeChanged.addHandler @onVideoProgressTimeChanged
    window.jukebox.onVideoLoadedProgressChanged.addHandler @onVideoLoadedProgressChanged
    window.jukebox.onLoadingNewPlaylist.addHandler @onLoadingNewPlaylist
    window.jukebox.onPlayerStateChanged.addHandler @onPlayerStateChanged
    window.jukebox.onPlayStateChanged.addHandler @onPlayStateChanged
    window.jukebox.onLoopChanged.addHandler @onLoopChanged
    window.jukebox.onShuffleChanged.addHandler @onShuffleChanged

    $(window).keypress @evKeyPress

  onLoadingNewPlaylist: (@playlist) =>
    @$('#now-playing-info').text "Loading playlist #{@playlist}..."

  onVideoChanged: (@videoInfo) =>
    @videoProgressTime = 0
    @totalPlayTime = @videoInfo.length
    @$('.progress .bar').css('width', (@videoProgressTime / @totalPlayTime) * 100 + '%')
    @render()

  onLoopChanged: (loopState) =>
    if not loopState
      @$('#loop').addClass 'disabled'
    else
      @$('#loop').removeClass 'disabled'

  onShuffleChanged: (shuffleState) =>
    if not shuffleState
      @$('#shuffle').addClass 'disabled'
    else
      @$('#shuffle').removeClass 'disabled'

  formatTime: (seconds) ->
    minutes = parseInt seconds / 60
    seconds = parseInt seconds % 60
    seconds = "0#{seconds}" if seconds < 10
    return "#{minutes}:#{seconds}"

  onPlayerStateChanged: (newState) =>
    @$('#volume').val window.jukebox.getVolume()
    @$('.progress .status-text').text('Buffering...') if newState is Jukebox.PlayerState.BUFFERING
    @$('.progress .status-text').text('Loading...') if newState is Jukebox.PlayerState.UNSTARTED

  onPlayStateChanged: (newState) =>
    if newState is Jukebox.PlayState.PLAYING
      @$('.media-controls #playpause i').removeClass().addClass('icon-pause')
    else
      @$('.media-controls #playpause i').removeClass().addClass('icon-play')

  onVideoProgressTimeChanged: (@videoProgressTime) =>
    @$('.progress .bar').css('width', (@videoProgressTime / @totalPlayTime) * 100 + '%')
    @$('.progress .status-text').text @formatTime @videoProgressTime

  onVideoLoadedProgressChanged: =>
    # TODO
    #@render()

  evPlayPause: (event) =>
    window.jukebox.togglePlayPause()

  evBack: (event) ->
    window.jukebox.playPrev()

  evNext: (event) ->
    window.jukebox.playNext()

  evShuffle: (event) ->
    window.jukebox.toggleShuffle()

  evLoop: (event) ->
    window.jukebox.toggleLoop()

  evProgressBarClicked: (event) =>
    offsetClicked = event.offsetX
    fullWidth = @$('#progress-bar').width()
    percentToProgressTo = offsetClicked / fullWidth
    window.jukebox.seekTo percentToProgressTo * @totalPlayTime

  evKeyPress: (event) =>
    if event.charCode is 32
      window.jukebox.togglePlayPause()
      return false

  evVolumeChanged: (event) =>
    window.jukebox.setVolume $(event.currentTarget).val()

  render: ->
    @$el.html template {
      details: window.jukebox.nowPlayingInfo() or 'Select a channel to begin!'
      progressPercent: (@videoProgressTime / @totalPlayTime) * 100
      statusText: 'Loading...'
      shuffle: window.jukebox.shuffle
      loop: window.jukebox.loop
    }

module.exports = PlayerControlsView
