<div class="row">
  <div class="span12" id="control-box">
    <div class="span12">
      <h3 id="now-playing-info">{{details}}</h3>
    </div>
    <div class="span8">
      <div class="progress" id="progress-bar">
        <div class="bar" style="width: {{progressPercent}}%"></div>
        <p class="status-text">{{statusText}}</p>
      </div>
    </div>
    <div class="span3 media-controls">
      <a id="back"><i class="icon-backward"></i></a>
      <a id="playpause"><i class="icon-play"></i></a>
      <a id="next"><i class="icon-forward"></i></a>
      <a id="shuffle" class="{{#unless shuffle}}disabled{{/unless}}"><i class="icon-random"></i></a>
      <a id="loop" class="{{#unless loop}}disabled{{/unless}}"><i class="icon-repeat"></i></a>
      <form class="volume-container">
        <input id="volume" min="0" max="100" step="1" type="range" />
      </form>
      <!--<a id="fullscreen"><i class="icon-fullscreen"></i></a>-->
    </div>
  </div>
</div>
