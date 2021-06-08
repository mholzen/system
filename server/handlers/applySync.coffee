getFunc = require './getFunc'

module.exports = (req, res, root)->
  func = getFunc req, res, root.mappers
  req.data = func.apply req.data, [ req.data ]
