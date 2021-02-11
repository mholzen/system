module.exports = (data, opts)->
  if true # opts?.req?.name?.endsWith '.cson'
    return CSON.parse data

  JSON.parse data
