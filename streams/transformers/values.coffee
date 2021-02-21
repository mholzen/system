stream = require '../../lib/stream'

create = (options)->
  (input)->
    input.flatMap (data)->
      stream data.values()

values = (data, options)->(create options) data

values.create = create

module.exports = values