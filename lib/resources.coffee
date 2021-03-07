# A tree that can be accessed by a path
class Resources extends Map
  constructor: ->
    super()
  set: (path, value)->
    # log.debug {path}
    if typeof path == 'string'
      path = path.split '/'

    # key = path[0]
    [key, rest...] = path
    if (path.length == 1) or (rest[0] == '')
      return super.set key, value

    if key == ''
      return super.set value
    if not super.has key
      resources = new Resources()
      super.set key, resources  
    else
      resources = super.get key

    if not (resources instanceof Resources)
      throw new Error "overwriting #{resources}"

    return resources.set path.slice(1), value

  get: (path)->
    if typeof path == 'string'
      path = path.split '/'

    key = path[0]
    value = super.get key
    # log.debug {value, key}
    return if path.length == 1
      value
    else
      if not (value instanceof Resources)
        throw new Error "trying to index #{value}"
      value.get path.slice 1
      
    # return super.get key.last()

module.exports = Resources
