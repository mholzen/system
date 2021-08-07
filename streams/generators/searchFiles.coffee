stream = require '../../lib/stream'
mappers = require '../../lib/mappers'

module.exports =
  create: (options)->
    query = options?.query

  # f = mappers name
  # if not f?   # TODO: encapsulate into mappers.get to:reuse
  #   throw new NotMapped name, mappers

    (data)->
      stream [data]
      .through stream.pipeline(
        stream.filter mappers.isFile
        stream.map (x)-> mappers.content x #, base: options.base
        stream.flatMap stream
        stream.map mappers.lines
        stream.map (x)-> x.map (y,i)-> { line: y, i: i }
        stream.map (x)-> x.filter (y)-> mappers.isTodo y.line # TODO: generalize using query  so:general
        stream.filter (x)-> x.length > 0
      )