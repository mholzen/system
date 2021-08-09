module.exports = (req, res)->
  if typeof req.data != 'function'
    throw new Error 'not a function'

  fn = req.data
  req.data = fn.call @