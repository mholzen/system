log = require '../log'

# TODO: should return a "unique" identifier for this data
module.exports = (data, options)->
  log {data, segments: options?.req?.params?.segments}
  if typeof data == 'string'
    if options?.req?.params?.segments? instanceof Array
      return options.req.params.segments.slice(-1)[0]

    return data

  data?.constructor.name
