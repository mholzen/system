getFunc = require './getFunc'

module.exports = (req, res)->
  func = getFunc req, res
  req.data = req.data.map (data)->
    func data
