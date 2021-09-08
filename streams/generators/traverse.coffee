stream = require '../../lib/stream'

# TODO: this should fail -> add test or remove
module.exports = (data, options)->
  stream traverse data, options
