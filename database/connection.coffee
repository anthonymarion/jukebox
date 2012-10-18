pg = require 'pg'
Pool = require 'generic-pool'

dbUrl = process.env.DATABASE_URL || 'localhost'
debug = false

exports.pool = pool = Pool.Pool
  name: 'postgres-db'
  create: (callback) ->
    pg.connect dbUrl, (err, client) ->
      callback null, client
  destroy: (client) ->
    client.end()
  max: 1
  idleTimeoutMillis: 1000
  log: debug

exports.query = (sql, sqlArgs, callback) ->
  (callback = sqlArgs; sqlArgs= []) if not callback? and typeof args is 'function'
  pool.acqurie (pErr, client) ->
    return callback(pErr) if pErr
    client.query sql, sqlArgs, (err, result) ->
      pool.release client
      callback err, result
