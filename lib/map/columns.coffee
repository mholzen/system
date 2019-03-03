module.exports = (options)->
  separator = /\s+/g
  (data)->
    if typeof data == 'string'
      return data.split separator

    throw new Error "cannot split #{typeof data}"