module.exports = (options)->
  (data)->
    if data?.length?
      return data.length

    throw new Error "cannot split #{typeof data}"