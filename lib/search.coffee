log = require '@vonholzen/log'
query = require './query'

search = (args...)->
  query.fromArgs(args).searchIn()

module.exports = search
