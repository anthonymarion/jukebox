#!/usr/bin/env coffee

youtube  =  require  'youtube-feeds'
_        =  require  './underscore'
express  =  require  'express'
redis    =  require  'redis'

app = express()

app.get '/refresh/:channel', (req, res) ->

app.get '/youtube/:channel', (req, res) ->
  youtube.feeds.videos { author: req.param('channel'), 'max-results': 50 }, (err, result) ->
    return res.send 500, err if err
    responseJson = _(result).pick 'startIndex', 'totalItems'
    responseJson.pages = Math.ceil(result.totalItems / result.itemsPerPage)
    responseJson.items = _(result.items).listPick 'id', 'title'
    res.json responseJson

app.get '/youtube/bare/:channel', (req, res) ->
  youtube.feeds.videos { author: req.param('channel'), 'max-results': 50 }, (err, result) ->
    return res.send 500, err if err
    res.json result

app.listen 3000
