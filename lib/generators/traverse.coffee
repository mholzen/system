module.exports = (options)->
  (data)->
    if typeof data == 'string'
      return data.split separator

    throw new Error "cannot split #{typeof data}"
