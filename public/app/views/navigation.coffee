template = Handlebars.compile require('templates')['navigation.mjs']
Jukebox = require '../libs/jukebox'

class NavigationView extends Backbone.View
  events:
    "click #quality.dropdown li": "evQualityChange"
    "click #channel.dropdown li": "evChannelChange"

  initialize: ->
    @render()

  evQualityChange: (event) =>
    window.jukebox.setQuality event.currentTarget.getAttribute 'data-value'

  evChannelChange: (event) =>
    window.jukebox.changeChannel event.currentTarget.getAttribute 'data-value'

  render: ->
    @$el.html template(
      qualities: Jukebox.getQualities()
      channels: Jukebox.getChannels()
    )

module.exports = NavigationView
