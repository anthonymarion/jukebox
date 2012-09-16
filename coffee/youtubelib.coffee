exports = module.exports || window

class exports.YoutubeRadio
  currentVideoIndex: -1
  playlist: {}
  player: null
  channelType: null
  channelFriendlyName: null
  stateChangeCallback: null
  songChangedCallback: null

  quality: 'large'
  shuffle: false
  loop: false
  playState: 'Paused'
  # Internal JSON request series ID. If we've moved on (for example changed the request mid-request), let's cancel the current series.
  currentJSONRequestId: 0
  # used to update the view for updates to any outstanding JSON requests
  requestUpdateCallback: null

  constructor: (@playerId) ->

  onPlayerReady: (playerId) ->
    @setPlayer document.getElementById playerId
    @playNext() if @channel?

  setSongChangedCallback: (@songChangedCallback) ->

  setPlayer: (@player) ->

  getPlayer: -> @player

  changeChannel: (user, playlistUpdateCallback) ->
    @getChannelAsync(user, @setPlaylistAs, playlistUpdateCallback) if user?

  changePlaylist: (playlist, playlistUpdateCallback) ->
    @getPlaylistAsync(playlist, @setPlaylistAs, playlistUpdateCallback) if playlist?

  getCurrentVideo: -> @playlist[@currentVideoIndex]

  toggleShuffle: -> @setShuffle !@shuffle

  setShuffle: (@shuffle) ->

  toggleLoop: -> @setLoop !@loop

  setLoop: (@loop) ->

  togglePlayPause: ->
    if @playState is 'Playing'
      @pause()
    else
      @playState = 'Playing'
      @player.playVideo()

  pause: ->
    @playState = 'Paused'
    @player.pauseVideo()

  playerStop: ->
    @playState = 'Stopped'
    @player?.stopVideo()

  setPlaylistAs: (radio, results, updateCallback) ->
    # reset the current video in the case of loading a new station
    if results.success
      radio.currentVideoIndex = -1

      radio.channel = results.identifier
      radio.channelType = results.type
      radio.channelFriendlyName = results.friendlyName
      radio.playList = results.videos
    else
      radio.channel = null
      radio.playlist = null
      radio.playerStop()

    updateCallback?(radio.playlist, results.success)

    radio.playNext() if results.success?

  setQuality: (@quality) ->
    @player?.setPlaybackQuality(@quality)

  playVideo: (playlistIndex) ->
    return if not ( @player and @playlist[playlistIndex] )

    video = @playlist[playlistIndex]
    oldVideoIndex = @currentVideoIndex
    @player.loadVideoById video.id, 0, @quality
    @currentVideoIndex = playlistIndex
    @playState = 'Playing'
    @songChangedCallback oldVideoIndex, playlistIndex


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

  getChannelAsync: (user, callback, playlistUpdateCallback, results=null) =>
    if results is null
      @currentJSONRequestId++
      results =
        type: 'channel'
        identifier: user
        # fixme: remove this channel field
        channel: user
        friendlyName: user
        seriesId: @currentJSONRequestId
        success: true
        videos: []

    # if the current request series doesn't match this path's request series, kill this.
    return if results .seriesId isnt @currentJSONRequestId

    feed = "http://gdata.youtube.com/feeds/api/videos?" +
      "alt=json&max-results=50&orderby=published&format=5&author=#{user}&start-index=#{results.videos.length + 1}"

    $.getJSON feed, {}, (data, textStatus, jqXHR) =>
      data = data.feed
      console.log data
      totalResults = data.openSearch$totalResults.$t

      if not data.entry and not results.videos.length?
        results.success = false
        callback this, results, playlistUpdateCallback
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
        @getChannelAsync user, callback, playlistUpdateCallback, results
      else
        callback this, results, palylistUpdateCallback

  getPlaylistAsync: (playlist, callback, playlistUpdateCallback, results) =>
    if results is null
      @currentJSONRequestId++
      results =
        type: 'playlist'
        identifier: playlist
        seriesId: @currentJSONRequestId
        success: true
        videos: []

    return if results.seriesId isnt @currentJSONRequestId

    feed = "http://gdata.youtube.com/feeds/api/playlists/#{playlist}?" + 
      "alt=json&max-results=50&format=5&start-index=#{results.videos.length + 1}"

    jQuery.getJSON feed, {}, (data, textStatus, jqXHR) =>
      data = data.feed
      totalResults = data.openSearch$totalResults.$t
      if not data.entrh and results.videos.length is 0
        results.success = false
        callback this, results, playlistUpdateCallback
        return
      $.each data.entry, (i, entry) ->
        href = entry.link[0].href
        results.videos.push
          title: entry.title.$t
          url: href
          id: href.substring href.lastIndexOf('?v=') + 3, href.lastIndexOf('&')
      results.friendlyName = data.title.$t
      if data.entry.length is 50 && results.videos.length < totalResults
        @requestUpdateCallback? {
          channelType: results.type
          identifier: playlist
          friendlyIdentifier: data.title.$t
          current: results.videos.length
          total: totalResults
        }
        @getPlaylistAsync playlist, callback, playlistUpdateCallback, results
      else
        callback this, results, playlistUpdateCallback
