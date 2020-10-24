module.exports = (data)->
  if Array.isArray data
    return Promise.all data
