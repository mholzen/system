log = require '../../lib/log'

toNumber = (data)->
  if Array.isArray data
    return data.map (x)->toNumber x

  if typeof data == 'string'
    if /^\d+$/.test data
      return parseInt data
  data

module.exports = (req, res, router)->
  if not (req.remainder?.length > 0)
    throw new Error "no items in req.remainder"

  req.data = req.remainder.shift()

  if req.data.includes ','
    req.data = req.data.split ','

  req.data = toNumber req.data