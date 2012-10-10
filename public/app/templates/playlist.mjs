<div class="row song">
  <div class="span12">
    <table class="table table-striped">
      <thead>
        <tr>
          <th></th>
          <th>Title</th>
          <th>Length</th>
        </tr>
      </thead>
      <tbody>
        {{#each songs}}
        <tr class="song" data-index="{{index}}">
          <td class="playing-indicator"><i></i> </td>
          <td>{{title}}</td>
          <td>{{formatSongTime length}}</td>
        </tr>
        {{/each}}
      </tbody>
    </table>
  </div>
</div>
