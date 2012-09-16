redis = require('redis').createClient()
redis.on 'error', (err) -> console.log "Redis Error: #{err}"

module.exports = redis
