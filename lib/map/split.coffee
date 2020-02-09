module.exports = (data, options)->
  sep = options[0] ? ' '
  if typeof data == 'string'
    return data.split sep
    
  data

