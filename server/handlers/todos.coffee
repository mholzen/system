request = require '../request'
parse = require '../../lib/mappers/parse'

module.exports = (req, res, router)->
  r = await request [
    'files'
    'generate,generators.stats'
    'transform,transformers.exclude,isImported'
    'transform,transformers.exclude,isGit'
    'transform,transformers.filter,isCode'
    'map,mappers.augment,generators.search,name:matches'
    'apply,mappers.resolve'
    'transform,transformers.filter,hasMatches'
    'map,mappers.pick,source.path,matches'
  ]

  # TODO: understand why matches has an array of an array of matches

  req.data = parse r.body