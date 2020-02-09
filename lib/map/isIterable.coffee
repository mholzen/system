module.exports = (data)->
  if typeof data?[Symbol.iterator] == 'function'
    return true

  false
