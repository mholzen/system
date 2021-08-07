{NotMapped} = require '../../lib/errors'
stream = require '../../lib/stream'
getFunction = require '../../lib/mappers/function'

module.exports =
  create: (name, options)->

    f = getFunction name, options

    key = options?.name ? name

    (source)->
      source.map (x)->
        Object.assign {},
          source: x
          [key]: stream([x]).through f
