stream = require '../../lib/stream'

create = (delim, options)->
  if not delim?
    delim = ','

  if typeof delim == 'string'
    # find column
    column = undefined
    return (data) ->
      data.flatMap (x)->
        log.debug 'split.flatMap', {x}
        x.split delim

  throw new Error "can't make split from '#{delim}', #{typeof delim}"

split = (data, delim, options)->(create delim, options) data

split.create = create

module.exports = split