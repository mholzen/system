request = require '../request'
parse = require '../../lib/mappers/parse'

module.exports = (req, res, router)->
  r = await request [
    'files'
    'generate', 'stats'
    'transform', 'exclude,isImported'
    'transform', 'exclude,isGit'
    'transform', 'filter,isCode'
    'map', 'augment,generators.search,name:matches'
    'apply', 'mappers.resolve'
    'transform', 'filter,hasMatches'
    'map', 'pick,source.path,matches'
  ]

  # TODO: understand why matches has an array of an array of matches

  req.data = parse r.body