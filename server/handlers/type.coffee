type = require '../../lib/mappers/type'
log = require '../../lib/log'

module.exports = (req, res, router)->
  name = req.remainder.shift()
  if not (name?.length > 0)
    return res.status(200).send Object.keys(type.types).sort()

  if not (header = type name, req)
    return res.status(404).send "'#{name}' not found"

  log.debug 'setting type', {header}
  res.type header