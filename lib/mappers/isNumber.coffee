module.exports = (data)->
  if typeof data == 'number'
    return true

  if typeof data == 'string'
    value = parseInt data
    if not isNaN value
      return true
