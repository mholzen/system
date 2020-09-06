{
  searchers
  log
} = require '../../lib'

module.exports = (req, res, router)->
  name = req.remainder.shift()
  req.data = searchers()
  if not name?  
    return
  if not name in req.data
    return res.status(404).send "'#{name}' not found in #{req.data}"
  req.data = req.data[name]
