fileStream = require '../../lib/mappers/fileStream'
stream = require '../../lib/mappers/stream'
lines = require './lines'
filter = require '../transformers/filter'
parse = require '../../lib/mappers/parse'


dir = 'data/marcvonholzen/develop/teamookla/embedded-performance/'

filteredStream = (filter, job)->
  stream fileStream dir + job
  .through lines
  .through filter.create filter
  .map parse

module.exports = (job)->
  platform: filteredStream 'isPlatform', job
  result: filteredStream 'isResult', job
  shaper: filteredStream 'isShaper', job
