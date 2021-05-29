getFunc = require './getFunc'

module.exports = (req, res)->
  func = getFunc req, res
  req.data = func.apply req.data, [ req.data ]
