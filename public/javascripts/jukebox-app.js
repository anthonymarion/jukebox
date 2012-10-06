(function() {
  var atts, params, videoId;

  params = {
    allowScriptAccess: "always"
  };

  atts = {
    id: "jukebox-yt-player"
  };

  videoId = "5ShagXWQ6jI";

  swfobject.embedSWF("http://www.youtube.com/v/" + videoId + "?enablejsapi=1&playerapiid=ytplayer&version=4", "jukebox-yt-player", "425", "356", "8", null, null, params, atts);

  window.onYouTubePlayerReady = function(playerId) {
    var channel, jukebox;
    channel = 'liquicity';
    jukebox = window.jukebox = new Jukebox("jukebox-yt-player");
    return jukebox.changeChannel(channel, function() {
      console.log('Channel changed!');
      return jukebox.playNext();
    });
  };

}).call(this);
