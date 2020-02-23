module.exports = (data, prefix, options)->
  if not prefix?
    throw new Error 'nothing to augment with'
  data.unshift prefix
  data
