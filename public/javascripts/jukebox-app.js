(function() {
  var atts, height, params, playerId, videoId, width;

  height = 1;

  width = 1;

  height = 640;

  width = 480;

  playerId = "jukebox-yt-player";

  videoId = "5ShagXWQ6jI";

  params = {
    allowScriptAccess: "always"
  };

  atts = {
    id: playerId
  };

  swfobject.embedSWF("http://www.youtube.com/v/" + videoId + "?enablejsapi=1&playerapiid=" + playerId + "&version=3", playerId, height, width, "8", null, null, params, atts);

  window.onYouTubePlayerReady = function(playerId) {
    var channel, jukebox, player;
    channel = 'liquicity';
    jukebox = window.jukebox = new Jukebox(playerId);
    jukebox.changeChannel(channel);
    player = document.getElementById(playerId);
    return player.addEventListener('onStateChange', 'Jukebox.onYoutubePlayerStateChange.fire');
  };

}).call(this);
