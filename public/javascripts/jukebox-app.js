(function() {
  var atts, height, params, playerId, videoId, width;

  height = $(window).height();

  width = $(window).width();

  playerId = "jukebox-yt-player";

  videoId = "5ShagXWQ6jI";

  params = {
    allowScriptAccess: "always"
  };

  atts = {
    id: playerId
  };

  swfobject.embedSWF("http://www.youtube.com/v/" + videoId + "?enablejsapi=1&playerapiid=" + playerId + "&version=3", playerId, width, height, "8", null, null, params, atts);

  window.onYouTubePlayerReady = function(playerId) {
    var channel, jukebox, player;
    channel = 'liquicity';
    jukebox = window.jukebox = new Jukebox(playerId);
    jukebox.changeChannel(channel);
    player = document.getElementById(playerId);
    player.addEventListener('onStateChange', 'Jukebox.onYoutubePlayerStateChange.fire');
    return $(window).resize(function() {
      player.setAttribute('height', $(window).height());
      return player.setAttribute('width', $(window).width());
    });
  };

}).call(this);
