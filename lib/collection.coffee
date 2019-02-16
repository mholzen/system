log = require './log'

# TODO: creates a collection with each entries twice

fromArray = (array)->
  array.forEach (item)->
    if not item.name?
      throw new Error "item #{item} has no name"

    if array[item.name]?
      throw new Error "item #{seacher} has duplicate name"

    array[item.name] = item

fromObject = (object)->
  array = []
  for name, value of object
    array.push value
    array[name] = value
  array

collection = (data)->
  if data instanceof Array
    return fromArray data

  if typeof data == 'object'
    return fromObject data

  throw new Error 'collection is neither Array nor object'

module.exports = collection
