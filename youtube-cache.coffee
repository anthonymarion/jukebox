youtube  =  require  'youtube-feeds'

module.exports = {
  getByAuthor: (author) ->
}

youtube.feeds.videos { author: req.param('channel'), 'max-results': 50 }, (err, result) ->
  return res.send 500, err if err
  responseJson = _(result).pick 'startIndex', 'totalItems'
  responseJson.pages = Math.ceil(result.totalItems / result.itemsPerPage)
  responseJson.items = _(result.items).listPick 'id', 'title'
  res.json responseJson
