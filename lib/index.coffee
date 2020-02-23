exports = [
  'compare'
  'generators'
  'inodes'
  'log'
  'mappers'
  'open'
  'parse'
  'post'
  'query'
  'reducers'
  'request'
  'resolve'
  'search'
  'searchers'
  'stream'
  'strings'
  'table'
].reduce (memo, d)->
  memo[d] = require "./#{d}"
  memo
, {}

module.exports = exports
