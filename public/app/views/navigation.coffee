template = Handlebars.compile require('templates')['navigation.mjs']
Jukebox = require '../libs/jukebox'

class NavigationView extends Backbone.View
  events:
    "click #quality.dropdown li": "handleQualityChange"

  initialize: ->
    @render()

  handleQualityChange: (ev) =>
    console.log 'in handleQualityChange', ev.currentTarget, ev.currentTarget.getAttribute 'data-value'
    window.jukebox.setQuality ev.currentTarget.getAttribute 'data-value'

  render: ->
    @$el.html template(
      qualities: Jukebox.getQualities()
    )

module.exports = NavigationView
