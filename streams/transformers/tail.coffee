stream = require '../../lib/stream'

module.exports =
  create: (options)->
    n = options?.n ? 10

    (source)->
      items = new Array n

      source.consume (err, x, push, next)->
        if err?
          push err
          next()
        else if x == stream.nil
          for n in items
            push null, n
          push null, stream.nil
        else
          items.push x
          if items.length > n
            items.shift()
          next()
