module.exports = (data, options)->
  separator = options?.separator ? /\s+/g
  if typeof data == 'string'
    return data.split separator

  throw new Error "cannot split #{typeof data}"
