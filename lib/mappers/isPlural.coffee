module.exports = (data)->
  log 'isPlural', {data}
  if typeof data == 'string'
    return data.slice(-1).toLowerCase() == 's'


