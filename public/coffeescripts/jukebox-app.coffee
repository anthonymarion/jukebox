params =
  allowScriptAccess: "always"
atts =
  id: "jukebox-yt-player"

videoId = "5ShagXWQ6jI"

swfobject.embedSWF "http://www.youtube.com/v/#{videoId}?enablejsapi=1&playerapiid=ytplayer&version=4", "jukebox-yt-player", "425", "356", "8", null, null, params, atts

window.onYouTubePlayerReady = (playerId) ->
  channel = 'liquicity'
  jukebox = window.jukebox = new Jukebox "jukebox-yt-player"
  jukebox.changeChannel channel, ->
    console.log 'Channel changed!'
    jukebox.playNext()
