fileStream = require '../../lib/mappers/fileStream'
stream = require '../../lib/mappers/stream'
lines = require './lines'
filter = require '../transformers/filter'
parse = require '../../lib/mappers/parse'

dir = 'data/marcvonholzen/develop/teamookla/embedded-performance/'

filteredStream = (filterName, job)->
  stream fileStream dir + job + '/log.txt'
  .through lines
  .through filter.create filterName
  .map parse

module.exports = (job)->
  streams = [
    filteredStream 'isPlatform', job
    filteredStream 'isResult', job
    filteredStream 'isShaper', job
  ]

  stream streams
  .zipAll0()
  .map (x)->
    result = x[1]
    result.platform = x[0][0][0].match(/Running a test on (.*) @/)[1]
    result.suite = x[2].SharedSuite
    result

