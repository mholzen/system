module.exports = (data, prefix, options)->
  if not prefix?
    throw new Error 'nothing to prepend with'
  data.unshift prefix
  data
