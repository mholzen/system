{NotMapped} = require '../../lib/errors'
{stream, isStream} = require '../../lib/stream'

module.exports = (data)->
  if stream.isStream data
    return data

  if typeof data == 'object'
    # this is too lose and captures objects and collections
    return stream Object.keys data

  if data instanceof Array
    return stream [0.. data.length-1]

  if typeof data == 'function'
    return stream [ data.name ]
 
  throw new NotMapped data, 'keys'
