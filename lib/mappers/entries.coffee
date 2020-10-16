module.exports = (data, options)->
  if typeof data == 'object'
    return Object.entries data