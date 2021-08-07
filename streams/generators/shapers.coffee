fileStream = require '../../lib/mappers/fileStream'
stream = require '../../lib/mappers/stream'
lines = require './lines'
filter = require '../transformers/filter'
parse = require '../../lib/mappers/parse'

module.exports = (job)->
  stream fileStream 'data/marcvonholzen/develop/teamookla/embedded-performance/' + job
  .through lines
  .through filter.create 'isShaper'
  .map parse
