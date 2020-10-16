module.exports = (data, options)->
  if data instanceof Buffer
    data = data.toString()

  if typeof data == 'string'
    if ['[', '{'].includes data?[0]
      return JSON.parse data
