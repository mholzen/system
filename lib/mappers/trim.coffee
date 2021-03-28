trim = (data, options)->

  # log.debug 'trim', {data}

  if data instanceof Buffer
    return data[0..10]

  if typeof data == 'object'
    for k, v of data
      data[k] = trim v, options
    return data

  if typeof data == 'string'
    return data.trim()
  
  data

module.exports = trim