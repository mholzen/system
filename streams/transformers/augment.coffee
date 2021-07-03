{NotMapped} = require '../../lib/errors'
stream = require '../../lib/stream'

module.exports =
  create: (name, options)->

    f = options.resolve name
    if not f?   # TODO: encapsulate into mappers.get to:reuse
      throw new NotMapped name, mappers

    key = options?.name ? name

    (source)->
      source.map (x)->
        Object.assign {},
          source: x
          [key]: stream([x]).through f
