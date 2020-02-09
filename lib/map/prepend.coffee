module.exports = (data, prefix, options)->
  if options.length < 1
    throw new Error 'nothing to augment with'
  data.unshift prefix
  data
