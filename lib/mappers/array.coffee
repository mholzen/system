module.exports = (data)->
  if data instanceof Array
    return data
  if data?.path?
    return data.path