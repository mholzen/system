module.exports = (data)->
  if data instanceof Map 
    Array.from data.keys()
  else
    Object.keys data
