type = require '../../lib/mappers/type'

module.exports = (req, res, router)->
  name = req.remainder.shift()
  if not (name?.length > 0)
    return res.status(200).send Object.keys(type.types).sort()

  if not (header = type name, req)
    return res.status(404).send "'#{name}' not found"

  res.type header