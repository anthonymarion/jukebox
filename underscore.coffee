module.exports = _ = require 'underscore'

_.mixin {
  listPick: (list, fields...) ->
    _.map list, (obj) ->
      _.pick obj, fields
}
