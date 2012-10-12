class Event
  handlers: null

  constructor: ->
    @handlers = []

  addHandler: (handler) ->
    @handlers.push handler

  fire: =>
    handler.apply(this, arguments) for handler in @handlers

class Jukebox
  @Quality: {
    SMALL:    'small'    #  240p
    MEDIUM:   'medium'   #  360p
    LARGE:    'large'    #  480p
    HD720:    'hd720'    #  720p
    HD1080:   'hd1080'   #  1080p
    HIGHRES:  'highres'  #  1080p+
  }

  @PlayerState: {
    UNSTARTED:  -1
    ENDED:      0
    PLAYING:    1
    PAUSED:     2
    BUFFERING:  3
    VIDEOCUED:  5
  }

  @PlayState: {
    PLAYING: 'Playing'
    PAUSED:  'Paused'
    STOPPED: 'Stopped'
  }

  @onYoutubePlayerStateChange: new Event()

  currentVideoIndex: -1
  playlist: {}
  player: null
  channel: null
  channelType: null
  channelFriendlyName: null
  stateChangeCallback: null
  quality: Jukebox.Quality.HIGHRES
  shuffle: false
  loop: false
  playState: @PlayState.PAUSED
  # Internal JSON request series ID. If we've moved on (for example changed the request mid-request), let's cancel the current series.
  currentJSONRequestId: 0
  # used to update the view for updates to any outstanding JSON requests
  requestUpdateCallback: null

  @updateRate: 100 # Update loop 10 times a second

  # Events
  onLoadingNewPlaylist:          new  Event()
  onPlaylistChanged:             new  Event()
  onPlayStatusChanged:           new  Event()
  onSongEnded:                   new  Event()
  onPlayerStateChanged:          new  Event()
  onPlayStateChanged:            new  Event()
  onVideoChanged:                new  Event()
  onVideoProgressTimeChanged:    new  Event()
  onVideoLoadedProgressChanged:  new  Event()
  onLoopChanged:                 new  Event()
  onShuffleChanged:              new  Event()

  constructor: (@playerId) ->
    @setPlayer document.getElementById(@playerId)

    @onPlayerStateChanged.addHandler @evPlayerStateChanged
    Jukebox.onYoutubePlayerStateChange.addHandler @onPlayerStateChanged.fire

    setTimeout @updateLoop, @updateRate

  evPlayerStateChanged: (state) =>
    @playNext() if state is Jukebox.PlayerState.ENDED

    @setPlayState Jukebox.PlayState.PLAYING if state is Jukebox.PlayerState.PLAYING
    @setPlayState Jukebox.PlayState.PAUSED if state is Jukebox.PlayerState.PAUSED
    @setPlayState Jukebox.PlayState.STOPPED if state is Jukebox.PlayerState.ENDED

  updateLoop: =>
    setTimeout @updateLoop, @updateRate
    return if not @player?

    #FIXME: Translate this to an actual time
    videoLoadedFraction = @player.getVideoLoadedFraction()
    if videoLoadedFraction isnt @videoLoadedFraction
      @videoLoadedFraction = videoLoadedFraction
      @onVideoLoadedProgressChanged.fire videoLoadedFraction

    videoProgressTime = @player.getCurrentTime()
    if videoProgressTime isnt @videoProgressTime
      @videoProgressTime = videoProgressTime
      @onVideoProgressTimeChanged.fire videoProgressTime

  setPlayer: (@player) ->
    # Set up the different event handlers
    @player

  changeChannel: (user) ->
    @getChannelAsync(user, @setPlaylistAs) if user? and user isnt @channel

  @getQualities: ->
    [
      { desc: 'Small (240p)', value: @Quality.SMALL }
      { desc: 'Medium (360p)', value: @Quality.MEDIUM }
      { desc: 'Large (480p)', value: @Quality.LARGE }
      { desc: 'HD-720p (720p)', value: @Quality.HD720 }
      { desc: 'HD-1080p (1080p)', value: @Quality.HD1080 }
      { desc: 'Highest Quality (1080p+)', value: @Quality.HIGHRES }
    ]

  # TODO: Some kind of editing here for this. Might need to be moved into a model/collection.
  @getChannels: ->
    [
      { id: 'liquicity', name: 'Liquicity' }
      { id: 'UKFMusic', name: 'UKF Music' }
      { id: 'UKFDubstep', name: 'UKF Dubstep' }
      { id: 'UKFMixes', name: 'UKF Mixes' }
      { id: 'UKFDrumAndBass', name: 'UKF Drum & Bass' }
      { id: 'karmincovers', name: 'Karmin Covers' }
    ]

  getCurrentVideo: ->
    @playlist[@currentVideoIndex]

  toggleShuffle: ->
    @setShuffle not @shuffle

  setShuffle: (@shuffle) ->
    @onShuffleChanged.fire @shuffle

  toggleLoop: ->
    @setLoop not @loop

  setLoop: (@loop) ->
    @onLoopChanged.fire @loop

  nowPlayingInfo: ->
    current = @getCurrentVideo()
    return if not current
    "#{current.title}"

  togglePlayPause: ->
    return @pause() if @playState is Jukebox.PlayState.PLAYING
    @play()

  setPlayState: (@playState) ->
    @onPlayStateChanged.fire @playState

  play: =>
    @player?.playVideo()

  pause: ->
    @player?.pauseVideo()

  stop: ->
    @player?.stopVideo()

  seekTo: (seconds) ->
    @player?.seekTo seconds

  setPlaylistAs: (results) =>
    # reset the current video in the case of loading a new station
    if results.success
      @currentVideoIndex = -1
      @channel = results.identifier
      @channelType = results.type
      @channelFriendlyName = results.friendlyName
      @playlist = results.videos
    else
      @channel = null
      @playlist = null
      @stop()
    @onPlaylistChanged.fire @playlist
    @playNext() if results.success? # TODO: maybe an autoplay setting?

  setQuality: (@quality) ->
    @player?.setPlaybackQuality(@quality)

  playVideo: (playlistIndex) ->
    playlistIndex = parseInt playlistIndex
    return if not ( @player and @playlist[playlistIndex] )

    video = @playlist[playlistIndex]
    oldVideoIndex = @currentVideoIndex
    @player.loadVideoById video.id, 0, @quality
    @currentVideoIndex = playlistIndex
    @play()

    @onVideoChanged.fire video

  playNext: ->
    if @shuffle && @playlist.length > 1
      nextVideo = Math.floor Math.random() * ( @playlist.length - 1)
      nextVideo++ if nextVideo >= @currentVideoIndex
    else if @loop
      nextVideo = (@currentVideoIndex + 1) % @playlist.length
    else
      nextVideo = @currentVideoIndex + 1

    @playVideo nextVideo

  playPrev: ->
    if @shuffle and @playlist.length > 1
      # TODO: should keep track of played tracks even through shuffle, and 'go back' properly
      prevVideo = Math.floor Math.random() * (@playlist.length -1)
      prevVideo++ if prevVideo >= @currentVideoIndex
    else if @loop
      prevVideo = (@currentVideoIndex - 1 + @playlist.length) % @playlist.length
    else
      prevVideo = @currentVideoIndex - 1

    @playVideo prevVideo

  setRequestUpdateCallback: (@requestUpdateCallback) ->

  # @param user string
  # @param callback function(results)
  # @param results object results from last call
  getChannelAsync: (user, callback, results=null) =>
    if results is null
      @onLoadingNewPlaylist.fire user
      results = {
        type: 'channel'
        identifier: user
        friendlyName: user
        seriesId: ++@currentJSONRequestId
        success: true
        videos: []
      }

    # if the current request series doesn't match this path's request series, kill this.
    return console.error("Killing request, request ID does not match") if results.seriesId isnt @currentJSONRequestId

    feed = "http://gdata.youtube.com/feeds/api/videos?" +
      "alt=json&max-results=50&orderby=published&format=5&author=#{user}&start-index=#{results.videos.length + 1}"

    $.getJSON feed, {}, (data, textStatus, jqXHR) =>
      data = data.feed
      totalResults = data.openSearch$totalResults.$t

      if not data.entry and not results.videos.length?
        results.success = false
        callback results
        return

      $.each data.entry, (i, entry) ->
        results.videos.push
          index: results.videos.length
          title: entry.title.$t
          url: entry.link[0].href
          id: entry.id.$t.substring(entry.id.$t.lastIndexOf('/') + 1)
          published: (new Date(entry.published.$t)).toDateString()
          length: entry.media$group.media$content[0]?.duration
          raw: entry

      if results.videos.length < totalResults
        @requestUpdateCallback? {
          channelType: results.type
          identifier: user
          friendlyIdentifier: user
          current: results.videos.length
          total: totalResults
        }
        @getChannelAsync user, callback, results
      else
        callback results

module.exports = Jukebox
