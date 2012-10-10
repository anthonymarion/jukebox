template = Handlebars.compile require('templates')['playlist.mjs']
Jukebox = require '../libs/jukebox'

Handlebars.registerHelper('formatSongTime', (seconds) ->
  minutes = parseInt seconds / 60
  seconds = parseInt seconds % 60
  seconds = "0#{seconds}" if seconds < 10
  return "#{minutes}:#{seconds}"
)

class PlaylistView extends Backbone.View
  events: {
    "click tr.song td": "evSongClicked"
  }
  
  # TODO:  class='icon-arrow-right'

  initialize: ->
    window.jukebox.onPlaylistChanged.addHandler @onPlaylistChanged
    window.jukebox.onVideoChanged.addHandler @onVideoChanged
    @render()

  onVideoChanged: (@video) =>
    @$('tr.song .playing-indicator i').removeClass 'icon-arrow-right'
    @$("tr.song[data-index='#{video.index}'] .playing-indicator i").addClass 'icon-arrow-right'

  onPlaylistChanged: (@playlist) =>
    @render()

  evSongClicked: =>
    "Song clicked"
    index = $(event.target).parent('tr').attr('data-index')
    window.jukebox.playVideo index if index

  render: =>
    @$el.html template {
      songs: @playlist
    }

module.exports = PlaylistView
