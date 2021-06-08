type = require '../../lib/mappers/type'
log = require '../../lib/log'

{base} = require '../../lib/mappers/html'

module.exports = (req, res, router)->
  name = req.remainder.shift()
  log.debug 'type entry', {name}
  if not (name?.length > 0)
    return res.status(200).send Object.keys(type.types).sort()

  if not (header = type name, req)
    return res.status(404).send "'#{name}' not found"

  log.debug 'setting type', {header}
  res.type header

  # if we're setting to html, set the base?
  if header == 'text/html'
    if req?.base?
      req.data = base(req.base) + req.data