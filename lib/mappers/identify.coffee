log = require '../log'

# TODO: should return a "unique" identifier for this data
module.exports = (data, options)->
  data?.constructor.name