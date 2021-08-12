# TODO: move to lib/mappers
toLiteral = (data)->
  # log.debug 'toLiteral.entry', {data}

  if Array.isArray data
    return data.map (x)->toLiteral x

  if typeof data == 'string'
    if /^\d+$/.test data
      return parseInt data

  data

module.exports = (req, res, router)->
  if not (req.remainder?.length > 0)
    throw new Error "no items in req.remainder"

  req.data = req.remainder.shift()

  if typeof req.data == 'number'
    return

  if typeof req.data == 'string'
    if req.data.includes ','
      req.data = req.data.split ','

  req.data = toLiteral req.data
