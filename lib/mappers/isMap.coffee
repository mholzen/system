isLiteral = require './isLiteral'
{isStream} = require '../stream'
values = require './values'

# distinguish between
#  objects that are collections, in the form of a map (all values have the same type) and
#  objects that are identities (values describe different facets of one identity) 

# this returns true if the data is a map
same = (array, f)->
  # log.debug 'same', {length: array.length, array}
  if not f
    f = (x)->x

  for value of array 
    if not prevValue?
      prevValue = f value
      continue
    value = f value
    if prevValue != value
      return false
    prevValue = value
  return true

module.exports = (data)->
  # log.debug 'isMap.entry', {data}

  if isLiteral data
    return false

  if isStream data
    return undefined

  if typeof data == 'object'
    # are all values of the same type?

    v = values data

    if same v, (x)->typeof x
      return true

    # log.debug 'isMap.return false'
    return false

  if typeof data == 'function'
    return false

  throw new Error "cannot evaluate isMap against '#{typeof data}' '#{log.print data}'"
      
