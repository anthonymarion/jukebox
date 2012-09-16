#!/usr/bin/env coffee

youtube  =  require  'youtube-feeds'
_        =  require  'underscore'

youtube.feeds.videos { author: 'liquicity' }, (err, result) -> # there is no error handling here?
  return console.log 'error:' + err if err
  console.log result
