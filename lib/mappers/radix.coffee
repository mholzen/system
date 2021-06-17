module.exports = (data, options)->
  radix = options?.radix ? 2

  if typeof data == 'string'
    data = Number.parseFloat data

  data.toString radix