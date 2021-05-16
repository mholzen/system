module.exports = (data)->
  if data instanceof Map 
    Array.from data.values()
  else
    Object.values data
