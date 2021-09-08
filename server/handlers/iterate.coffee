augmentArgsMapper = require './augmentArgsMapper'
stream = require '../../lib/mappers/stream'

module.exports = (req, res, router)->
  augmentArgsMapper req, res
  func = req.mapper
  args = req.args

  req.data = stream func req.data, args.options
