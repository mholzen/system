log = require '@vonholzen/log'
query = require './query'

searchers = require './searchers'

search = (args...)->
  query(args).searchIn searchers

module.exports = search
