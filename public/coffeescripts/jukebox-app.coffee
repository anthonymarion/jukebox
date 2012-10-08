height = $(window).height()
width = $(window).width()

playerId = "jukebox-yt-player"
videoId = "5ShagXWQ6jI"

params =
  allowScriptAccess: "always"
atts =
  id: playerId
swfobject.embedSWF "http://www.youtube.com/v/#{videoId}?enablejsapi=1&playerapiid=#{playerId}&version=3", playerId, width, height, "8", null, null, params, atts

window.onYouTubePlayerReady = (playerId) ->
  channel = 'liquicity'
  jukebox = window.jukebox = new Jukebox playerId
  jukebox.changeChannel channel

  player = document.getElementById playerId
  player.addEventListener 'onStateChange', 'Jukebox.onYoutubePlayerStateChange.fire'

  $(window).resize ->
    player.setAttribute 'height', $(window).height()
    player.setAttribute 'width', $(window).width()
