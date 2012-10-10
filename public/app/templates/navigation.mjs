<div class="navbar">
  <div class="navbar-inner">
    <div class="brand" href="#">Jukebox</div>
    <ul class="nav">
      <li id="quality" class="dropdown">
      <a class="dropdown-toggle" data-toggle="dropdown" href="#">Quality</a>
      <ul class="dropdown-menu" role="menu">
        {{#each qualities}}
        <li data-value="{{value}}"><a>{{desc}}</a></li>
        {{/each}}
      </ul>
      </li>
      <li id="channel" class="dropdown">
      <a class="dropdown-toggle" data-toggle="dropdown" href="#">Channel</a>
      <ul class="dropdown-menu" role="menu">
        {{#each channels}}
        <li data-value="{{id}}"><a>{{name}}</a></li>
        {{/each}}
      </ul>
      </li>
    </ul>
    <ul class="nav pull-right">
      <li>
        <a>B-b-but its a b-b-beta</a>
      </li>
    </ul>
  </div>
</div>
