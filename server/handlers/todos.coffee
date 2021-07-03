request = require '../request'
parse = require '../../lib/mappers/parse'

module.exports = (req, res, router)->
  # TODO: implement search in order to find todos
  # req.data = request 'files/apply/search,todo'
  r = await request [
    'files'
    'generate', 'stats'
    'transform', 'exclude,isImported'
    'transform', 'exclude,isGit'
    'transform', 'filter,isCode'
    'transform', 'augment,search,name:matches'
    'apply', 'resolve'
    'transform', 'filter,hasMatches'
    'map', 'pick,source.path,matches'
  ]
  req.data = parse r.body