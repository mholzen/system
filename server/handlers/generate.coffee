augmentArgsMapper = require './augmentArgsMapper'

module.exports = (req, res, router)->
  augmentArgsMapper req, res
  func = req.mapper
  args = req.args

  req.data = func req.data, args.options
