getArray = require './array'
{NotMapped} = require '../errors'

module.exports = (data, options)->
  log.debug 'filter', {data, options}
  data = getArray data
  if not data?
    throw new NotMapped data, 'filter'

  data.filter (x)-> x.includes '# TODO'
