exports = window || module.exports

PLAYING = 'Playing'
PAUSED = 'Paused'
STOPPED = 'Stopped'

class exports.Jukebox
  currentVideoIndex: -1
  playlist: {}
  player: null
  channelType: null
  channelFriendlyName: null
  stateChangeCallback: null
  quality: 'large'
  shuffle: false
  loop: false
  playState: PAUSED
  # Internal JSON request series ID. If we've moved on (for example changed the request mid-request), let's cancel the current series.
  currentJSONRequestId: 0
  # used to update the view for updates to any outstanding JSON requests
  requestUpdateCallback: null

  # TODO: make events: onPlaylistChanged, onPlayStatusChanged

  constructor: (@playerId) ->
    @player = document.getElementById(@playerId)

  changeChannel: (user) ->
    @getChannelAsync(user, @setPlaylistAs) if user?

  getCurrentVideo: ->
    @playlist[@currentVideoIndex]

  toggleShuffle: ->
    @setShuffle not @shuffle

  setShuffle: (@shuffle) ->

  toggleLoop: ->
    @setLoop not @loop

  setLoop: (@loop) ->

  togglePlayPause: ->
    return @pause() if @playState is PLAYING
    @play()

  play: ->
    @playState = PLAYING
    @player?.playVideo()

  pause: ->
    @playState = PAUSED
    @player?.pauseVideo()

  stop: ->
    @playState = STOPPED
    @player?.stopVideo()

  setPlaylistAs: (results, updateCallback) =>
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
    updateCallback(@playlist, results.success) if updateCallback
    @playNext() if results.success?

  setQuality: (@quality) ->
    @player?.setPlaybackQuality(@quality)

  playVideo: (playlistIndex) ->
    return if not ( @player and @playlist[playlistIndex] )

    video = @playlist[playlistIndex]
    oldVideoIndex = @currentVideoIndex
    @player.loadVideoById video.id, 0, @quality
    @currentVideoIndex = playlistIndex
    @playState = PLAYING

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
      nextVideo = @currentVideoIndex - 1

    @playVideo prevVideo

  setRequestUpdateCallback: (@requestUpdateCallback) ->

  # @param user string
  # @param callback function(results)
  # @param results object results from last call
  getChannelAsync: (user, callback, results=null) =>
    results = {
      type: 'channel'
      identifier: user
      friendlyName: user
      seriesId: ++@currentJSONRequestId
      success: true
      videos: []
    } if results is null

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
          title: entry.title.$t
          url: entry.link[0].href
          id: entry.id.$t.substring(entry.id.$t.lastIndexOf('/') + 1)

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

