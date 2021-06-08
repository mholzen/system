getFunc = require './getFunc'

module.exports = (req, res, root)->
  func = getFunc req, res, root.mappers
  req.data = req.data.map (data)->
    func data
